import { API_URL, PROCESSED_BUCKET_URL } from './config.js';

document.getElementById('uploadButton').addEventListener('click', async () => {
    const fileInput = document.getElementById('fileInput');
    const file = fileInput.files[0];
    const status = document.getElementById('status');
    const gallery = document.getElementById('gallery');

    if (!file) {
        status.textContent = 'Please select a file first.';
        return;
    }

    status.textContent = 'Preparing to upload...';

    try {
        // Step 1: Get presigned URL
        const response = await fetch(API_URL, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ fileName: file.name, fileType: file.type })
        });

        const data = await response.json();
        const presignedUrl = data.uploadURL;
        const uniqueKey = data.key; // This is the key your Lambda uses

        status.textContent = 'Uploading...';

        // Step 2: Upload to S3
        await fetch(presignedUrl, {
            method: 'PUT',
            body: file,
            headers: { 'Content-Type': file.type }
        });

        status.textContent = 'Upload successful! Waiting for processing...';

        // Step 3: Poll for processed image
        const maxRetries = 20;
        let retries = 0;
        let processedUrl = `${PROCESSED_BUCKET_URL}/${uniqueKey}`; // Assuming same key in processed bucket

        while (retries < maxRetries) {
            try {
                const res = await fetch(processedUrl, { method: 'HEAD' });
                if (res.ok) {
                    // Processed image exists
                    const img = document.createElement('img');
                    img.src = processedUrl;
                    img.style.maxWidth = '300px';
                    gallery.appendChild(img);
                    status.textContent = 'Processing complete!';
                    break;
                }
            } catch (err) {
                // ignore
            }
            await new Promise(r => setTimeout(r, 1500)); // wait 1.5 sec
            retries++;
        }

        if (retries === maxRetries) {
            status.textContent = 'Processing timed out. Try again later.';
        }

    } catch (error) {
        status.textContent = 'Upload failed. Please try again.';
        console.error('Error:', error);
    }
});
