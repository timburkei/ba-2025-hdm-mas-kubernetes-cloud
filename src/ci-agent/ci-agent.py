from fastapi import FastAPI, Depends, File, HTTPException, UploadFile, Form
import io, os, uuid, json, base64
from PIL import Image
import logging
from azure.storage.blob import BlobServiceClient
from azure.core.exceptions import ResourceExistsError
from azure.servicebus import ServiceBusClient, ServiceBusMessage
from pydantic import BaseModel

app = FastAPI()

logging.basicConfig(level=logging.INFO)

azure_storage_connection_string = os.getenv("AZURE_BLOB_STORAGE_CONNECTION_STRING")
input_azure_storage_container_name = os.getenv("INPUT_AZURE_BLOB_STORAGE_CONTAINER_NAME")
input_service_bus_connection_string = os.getenv("INPUT_SERVICE_BUS_CONNECTION_STRING")
input_service_bus_queue_name = os.getenv("INPUT_SERVICE_BUS_QUEUE_NAME")

if not azure_storage_connection_string:
    raise ValueError("INPUT_AZURE_BLOB_STORAGE_CONNECTION_STRING is required")
if not input_azure_storage_container_name:
    raise ValueError("INPUT_AZURE_BLOB_STORAGE_CONTAINER_NAME is required")
if not input_service_bus_connection_string:
    raise ValueError("INPUT_SERVICE_BUS_CONNECTION_STRING is required")
if not input_service_bus_queue_name:
    raise ValueError("INPUT_SERVICE_BUS_QUEUE_NAME is required")

class ImageUploadRequest(BaseModel):
    image: str
    load_testing_id: str


blob_service_client = BlobServiceClient.from_connection_string(azure_storage_connection_string)
service_bus_client = ServiceBusClient.from_connection_string(input_service_bus_connection_string)


async def get_blob_container_client():
    container_client = blob_service_client.get_container_client(input_azure_storage_container_name)
    if not container_client.exists():
        logging.info("Container does not exist. Creating new container")
        container_client.create_container()
    return container_client

async def get_service_bus_sender():
    sender = service_bus_client.get_queue_sender(input_service_bus_queue_name )
    return sender

class ImageUploadRequest(BaseModel):
    image: str
    load_testing_id: str


@app.post("/upload")
async def  upload_image(request: ImageUploadRequest, container_client=Depends(get_blob_container_client), sb_sender=Depends(get_service_bus_sender)):
    try:
        if not request.image.startswith("data:image/jpeg;base64,"):
            raise HTTPException(status_code=400, detail="Only JPEG base64 images are supported")

        base64_data = request.image.replace("data:image/jpeg;base64,", "")
        image_data = base64.b64decode(base64_data)
        image = Image.open(io.BytesIO(image_data))
        logging.info(f"Image loaded successfully, Größe: {image.size}")

        filename = f"{request.load_testing_id}.jpg"
        image_byte_arr = io.BytesIO()
        image.save(image_byte_arr, format='JPEG')
        image_byte_arr = image_byte_arr.getvalue()

        blob_client = container_client.get_blob_client(filename)
        blob_client.upload_blob(image_byte_arr, blob_type="BlockBlob", overwrite=True)
        blob_url = blob_client.url
        logging.info(f"Image uploaded successfully: {blob_url}")

        fipa_acl_message = {
            "performative": "inform",
            "sender": "cia",
            "receiver": "ica",
            "content": {
                "image_uploaded": filename,
                "url": blob_url,
                "load_testing_id": request.load_testing_id
            },
            "language": "ACL",
            "encoding": "UTF-8"
        }

        message = ServiceBusMessage(json.dumps(fipa_acl_message))
        with sb_sender:
            sb_sender.send_messages(message)

        return {"message": "Image uploaded successfully", "url": blob_url}


    except Exception as e:
        logging.error(f"Error uploading image: {e}")
        raise HTTPException(status_code=500, detail="Internal Server Error")

