# Headphones Module Refactoring

This module has been refactored to make it easier to add new headphone models in the future.

## Key Changes

1. **Modular Feature System**:

    - Each feature (ANC, Double-Tap, Hold gesture, etc.) is now in a separate file
    - Features are in `huawei/features/` directory

2. **Generic Settings Class**:

    - Replaced model-specific settings with generic `HuaweiHeadphonesSettings`
    - Settings structure can be shared across different models

3. **Model Definition System**:

    - Created a flexible model definition system in `huawei/model_definition.dart`
    - Each model specifies which features it supports and default settings

4. **Unified Implementation**:
    - Replaced model-specific implementation with a generic implementation
    - The same implementation can be used for all Huawei models

## Files to Delete

The following files are no longer needed and can be deleted:

- `huawei/freebudspro3.dart`
- `huawei/freebudspro3_impl.dart`
- `huawei/freebudspro3_sim.dart`

## How to Add a New Model

To add a new Huawei headphone model:

1. Add a new model definition in `huawei/model_definition.dart`:

   ```dart
   static final newModel = HuaweiModelDefinition(
     name: "Model Name",
     idNameRegex: RegExp(r'^(?=(HUAWEI Model Name))', caseSensitive: true),
     imageAssetPath: 'path/to/image.png',
     supportsAnc: true,
     // ... specify which features it supports
     defaultSettings: const HuaweiHeadphonesSettings(...),
   );
   ```

2. Add the model to the `allModels` list:
   ```dart
   static final List<HuaweiModelDefinition> allModels = [
     freeBudsPro3,
     freeBuds4i,
     newModel,  // Add your new model here
   ];
   ```

That's it! No need to create any additional implementation files.
