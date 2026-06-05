# CAMSCAN Backend

This is the backend for the CAMSCAN attendance system.

## Deployment (Vercel)

1. Install Vercel CLI: `npm i -g vercel`
2. Run `vercel` in the project root.
3. Add environment variables in Vercel Dashboard:
   - `MONGODB_URI`: Your MongoDB Atlas connection string.
   - `DB_NAME`: `camscan`

## Local Setup

1. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

2. Configure environment:
   - Copy `.env.example` to `.env`
   - Update `MONGODB_URI` with your Atlas string.

3. Run the server:
   ```bash
   python main.py
   ```

The server will be available at `http://localhost:8000`.

## API Endpoints

- `GET /api/courses`: Fetch list of courses.
- `POST /api/sessions/bulk-upload`: Upload attendance sessions in bulk.
