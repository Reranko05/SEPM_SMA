Sample API requests/responses

1) Register
POST /api/auth/register
Request:
{
  "username": "alice",
  "password": "secret",
  "fullName": "Alice"
}
Response:
{
  "token": "<jwt>"
}

2) Login
POST /api/auth/login
Request:
{
  "username": "alice",
  "password": "secret"
}
Response:
{
  "token": "<jwt>"
}

3) Get Recommendation
GET /api/recommendation
Header: Authorization: Bearer <jwt>
Response 200:
{
  "id":"m2",
  "name":"Vegan Bowl",
  "calories":600,
  "price":8.0,
  "rating":4.8,
  "dietType":"VEGAN"
}
