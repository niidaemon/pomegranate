import { Router } from "express";

export const apiRoutes = Router();

apiRoutes.get("/", (req, res) => {
  res.json({
    message: "API is working!",
    version: "1.0.0"
  });
});

apiRoutes.get("/users", (req, res) => {
  res.json({
    users: [
      { id: 1, name: "John Doe", email: "john@example.com" },
      { id: 2, name: "Jane Smith", email: "jane@example.com" }
    ]
  });
});

apiRoutes.post("/users", (req, res) => {
  const { name, email } = req.body;
  
  if (!name || !email) {
    return res.status(400).json({
      error: "Name and email are required"
    });
  }
  
  res.status(201).json({
    message: "User created successfully",
    user: { id: Date.now(), name, email }
  });
});
