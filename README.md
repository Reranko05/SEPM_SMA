<!--
  Production-quality README for SMA2 (Smart Meal Assistant)
  Generated: 2026-05-03
-->
# Smart Meal Autopilot (SMA)
## AI-powered meal planning with nutrition and budget optimization

_Smart, nutrition-aware meal recommendations and automated meal prep for busy lives_

<!-- Badges -->
[![Flutter](https://img.shields.io/badge/Flutter-2.10-blue.svg)](https://flutter.dev)
[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.0-green.svg)](https://spring.io/projects/spring-boot)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-14-blue.svg)](https://www.postgresql.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

<!-- Logo placeholder -->
![Project Logo](docs/assets/logo-placeholder.png)

## Screenshots
Screenshots are intentionally minimal here; replace the placeholders with high-fidelity images from `/frontend/screenshots/`.

- Dashboard (Upcoming Meal & Recommendations): `docs/screenshots/dashboard.png`
- Preferences (diet, times, budget): `docs/screenshots/preferences.png`
- Cart & Instant Fill: `docs/screenshots/cart.png`

## Key Features
SMA2 delivers nutrition-aware meal recommendations with practical automation for daily life. Unlike simple recommender apps, SMA2 generates multi-item combos that collectively satisfy calorie, protein, carbohydrate and budget constraints. The system can automatically schedule an “auto-fill” before configured meal times, populating the user’s cart with a recommended combo so orders are ready when needed.

- Constraint-driven combo planning: generates multiple-dish combos, not single-item suggestions.
- User-configurable nutrition and budget preferences (calories, protein, carbs, budget in INR ₹).
- Automated scheduler that auto-fills the cart shortly before mealtime (test mode available for development).
- Full-stack integration: Flutter frontend, Spring Boot backend, PostgreSQL persistence.

## Tech Stack
- Frontend: Flutter (Provider state management, android_alarm_manager_plus for scheduling, flutter_local_notifications)
- Backend: Java, Spring Boot, Maven
- Database: PostgreSQL (development uses local instance or Docker)

## Architecture Overview
SMA2 is a two-tier architecture with a mobile frontend and a RESTful backend. The frontend manages user preferences, schedules, and UI; it communicates with the backend for recommendations, cart operations, and planner computations. The backend implements the recommendation engine and a constraint-based MealPlannerService which produces balanced combos. A scheduler component (frontend) triggers background fills based on provider-managed preferences.

Flow: Preferences → Recommendation Service → Meal Planner → Scheduler → Cart

## How It Works (high level)
1. The user defines dietary preferences and desired nutrition targets in the Preferences screen.
2. The frontend requests recommendations from the backend recommendation API for the given user profile.
3. The backend's MealPlannerService produces a combo (multiple menu items) that collectively aims to match the nutrition targets and stay within budget.
4. The user may accept suggestions manually or enable scheduled auto-fill. When enabled, the scheduler triggers a background job before the configured meal time and posts the recommended combo to the cart endpoint.
5. The cart supports instant-fill, modification, and checkout using existing backend APIs.

## Installation
These instructions assume you have Java 17+, Maven, Flutter SDK, and PostgreSQL installed. Adjust versions according to your environment.

### Backend (Spring Boot)
1. Configure PostgreSQL and create a database (e.g., `sma2`):

```bash
psql -c "CREATE DATABASE sma2;"
```

2. Copy `.env.example` to `.env` or set environment variables used by `application.properties` (DB URL, username, password, server port).

3. Build and run the backend:

```bash
cd backend
mvn -DskipTests package
mvn spring-boot:run
```

Default backend port: `8080`. API base URL used by the frontend: `http://localhost:8080/api`.

### Frontend (Flutter)
1. Ensure Flutter is installed and your device/emulator is available.
2. From the `frontend` directory, run:

```bash
cd frontend
flutter pub get
flutter analyze
flutter run -d <device-id>
```

Notes:
- The frontend expects the backend API at `http://localhost:8080/api` by default. Update `lib/config.dart` (or the provider) to change the API URL for mobile devices/emulators.
- For Android background scheduling, ensure the `android_alarm_manager_plus` setup steps are included in `android` module config.

## Environment & Ports
- Backend: `http://localhost:8080` (REST API under `/api`)
- Frontend (dev): `flutter run` on device or emulator
- Database: PostgreSQL default port `5432`

## Usage
1. Start the backend and ensure DB migrations (if any) are applied.
2. Run the frontend on an emulator/device.
3. Register or login as a user, open Preferences and set nutrition targets and meal times.
4. Use the Recommendations view to preview combos; enable “Instant Fill” or schedule auto-fill for automatic cart population.

## Demo / Testing Key Features
- Generate recommendations: Use the Recommendations endpoint from the app to get combos tailored to your profile.
- Combo planner validation: Confirm each recommended combo lists multiple items whose summed nutrition approximates configured targets.
- Scheduler test mode: The app includes a test-mode scheduler that shortens intervals for development — toggle it in Preferences and verify the background callback posts all combo items to the cart.

Example backend API calls (curl):

```bash
# Get recommendations
curl "http://localhost:8080/api/recommendations?username=test"

# Add combo items to cart
curl -X POST "http://localhost:8080/api/cart?username=test" -H "Content-Type: application/json" -d '[{"mealId":1,"qty":1},{"mealId":2,"qty":1}]'
```

## Project Folder Structure (brief)

- `backend/` — Spring Boot service (REST API, planner, recommendation logic)
- `frontend/` — Flutter mobile app (screens, providers, services)
- `docs/` — design assets, screenshots, logo placeholders
- `build/` — build artifacts (ignored in VCS)

## Differentiators
- Combo-first planning: the MealPlannerService optimizes sets of dishes together to meet nutrition targets rather than recommending single items.
- Automated scheduler: a first-class auto-fill scheduler populates the cart ahead of meal time, enabling smoother order workflows.
- Nutrition-aware constraints: the planner respects calories, protein, carbs, and budget constraints when forming combos.
- Production-grade full-stack integration: clean separation between Flutter UI and Spring Boot planner, with PostgreSQL persistence.

## Future Improvements
- Add unit and integration tests for MealPlannerService combos and recommendation correctness.
- Add A/B testing for recommendation variants and UX flow analytics.
- Reintroduce server-side cron-based recommender for server-initiated workflows (optional).
- Improve combo diversity with additional dietary constraints (allergies, ingredient-level exclusions).

## Author
SMA2 Team — repository maintained at `d:/VSCode/sma2`. For questions or contributions, open an issue or submit a pull request.

---
For deployment, CI, and security hardening guidelines, add `docs/DEPLOY.md` and `docs/SECURITY.md` as next steps.
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
