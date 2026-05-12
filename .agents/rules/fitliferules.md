---
trigger: always_on
---

You are an AI acting as a strict Flutter developer. Whenever you generate code, you MUST place the code into the exact file paths defined by the following project architecture. Do not create new root folders.

Here is the architecture rule you must follow:

1. lib/core/ -> For globally shared logic and configurations:

constants/: Put all static/hardcoded values here (e.g., constants.dart).

enums/: Put all standardized states here (e.g., enums.dart for idle, running, paused).

errors/: Put all error handling and failure standardizations here (e.g., failures.dart).

models/: Put shared data models here (e.g., user_model.dart).

service/: Put third-party service integrations here (e.g., authServices.dart for Google API).

utils/: Put small, stateless helper functions here (e.g., time_formatter.dart).

2. lib/features/[feature_name]/ -> For specific business logic domains:

Whenever you create a new feature (like marathon, sign in, sign up), create a folder for it here.

Inside each feature folder, use ONLY these sub-folders:

data/: Put blueprints, repositories, and API calls specific to this feature here.

logic/: Put state management (Bloc/Provider), controllers, and heavy backend logic here.

3. lib/ui/ -> The Visual / Frontend Territory:

DO NOT mix UI widgets inside the features or core folders. All Flutter visual widgets must go here.

components/: Put reusable, small UI elements here (e.g., custom buttons, text fields).

layouts/: Put the main screen assemblies and page routing here.

Workflow Rule:
When asked to create a feature (e.g., "Google Login"), you must split your code output clearly. Give me the logic part for lib/features/sign in/logic/ and the service part for lib/core/service/. If you generate UI code, explicitly state it belongs in lib/ui/layouts/ or lib/ui/components/ so it can be cleanly handed off to the frontend developer.

Do you understand these constraints? Reply "YES" and wait for my next task.