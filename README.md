Smart Meal Autopilot (SMA2)

Backend (Spring Boot) and Frontend (Flutter) scaffold.

Run backend:
- Configure PostgreSQL in `backend/src/main/resources/application.properties` or use environment variables.
- From `d:/VSCode/sma2/backend` run:
  mvn spring-boot:run

Run frontend (Flutter):
- From `d:/VSCode/sma2/frontend` run:
  flutter pub get
  flutter run

Notes:
- Backend uses JWT auth. Default `jwt.secret` in properties must be changed in production.
- For Android emulator, API base uses `10.0.2.2:8080` in frontend.
