# Application Architecture

## Overview
This project follows Clean Architecture principles to ensure scalability,
testability, and separation of concerns.

---

## Layers

### 1. Presentation Layer
- Flutter UI
- Riverpod providers
- No business logic

### 2. Domain Layer
- Entities
- Repository contracts
- Use cases (optional for this scope)

### 3. Data Layer
- Mock REST APIs
- Mock Socket services
- DTO to domain mapping
- Local cache (Hive)

---

## State Management
Riverpod is used for:
- Dependency injection
- Async state handling
- Optimized rebuilds

---

## Data Flow
UI → Provider → Repository → Data Source  
Socket → Stream → Provider → UI

---

## Mock Strategy
- REST APIs simulated using Future.delayed
- Real-time updates simulated using StreamController
- Architecture remains backend-agnostic
