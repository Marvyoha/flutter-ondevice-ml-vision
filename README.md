# CIFAR Lens — On-Device CIFAR-10 Classifier

**CIFAR Lens** is a Flutter app that performs real-time on-device image classification for the 10 CIFAR-10 classes using a post-training INT8-quantized TFLite model. Inference runs locally with no network calls, ~0.73 ms/image on CPU, and 0.61 MB model size.

## Demo

<video src="https://github.com/user-attachments/assets/c253c543-8813-4c60-9b9c-cac2ae2a0409" width="600" autoplay loop muted playsinline></video>

## Features

- Capture from camera or import from gallery
- On-device INT8 inference (`cnn_model_int8.tflite`)
- Onboarding flow with best-practice capture tips (40-60% fill, plain background, good lighting)
- Confidence gating with calibrated 10-class threshold (0.45)
- Live latency readout and full per-class probability view
- Privacy-first: all processing stays on the device

## Model Overview

Trained and quantized in-repo and documented in https://github.com/Marvyoha/pytorch-tflite-quantisation.

**Artifacts**
- `models/cnn_model_int8.tflite` — INT8 post-training quantized TFLite model
- `models/cifar10.pth` — Best PyTorch checkpoint (training reference)
- `models/cnn_model.onnx` — ONNX export (training reference)
- `graphs/confusion_matrix.png`, `graphs/roc_curve.png` — Evaluation visuals

**Benchmarks**
| Metric | Value |
|---|---|
| PyTorch Test Accuracy | 79.93% |
| TFLite INT8 Test Accuracy | 80.02% |
| Precision (macro) | 79.92% |
| Recall (macro) | 79.93% |
| F1-Score (macro) | 79.62% |
| ROC-AUC | 0.9786 |
| Latency (TFLite CPU) | ~0.73 ms / image |
| Model size | 0.61 MB |

**Classes**
1. plane, 2. car, 3. bird, 4. cat, 5. deer, 6. dog, 7. frog, 8. horse, 9. ship, 10. truck

## TFLite Model Specs

**Input**
- Shape: `[1, 32, 32, 3]`
- Dtype: `int8`
- Quantization: `scale = 0.003921568859368563`, `zero_point = -128`
- Preprocess: `q = pixel_rgb - 128` clamped to `[-128, 127]`, RGB order, resize to 32x32 with linear interpolation

**Output**
- Shape: `[1, 10]`
- Dtype: `int8`
- Quantization: `scale = 0.11211809515953064`, `zero_point = -2`
- Dequantize: `logit = (q - (-2)) * 0.112118095...`, then softmax over 10 logits

**Recommended UI confidence threshold**: 0.45–0.55 (0.45 used in code).

## Tech Stack

- Flutter 3.12+, Dart 3.x
- `flutter_riverpod` for state management
- `tflite_flutter` for on-device inference
- `image_picker` for camera/gallery
- `image` for resize / preprocessing
- `google_fonts` (Space Grotesk)
- `flutter_secure_storage` for onboarding persistence

## Getting Started

```bash
# clone
git clone https://github.com/Marvyoha/flutter-ondevice-ml-vision.git
cd flutter-ondevice-ml-vision

# install dependencies
flutter pub get

# run
flutter run
```

Make sure `assets/models/cnn_model_int8.tflite` is present and declared in `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/models/
```

## Project Structure

```
lib/
  main.dart                 # App entry, ProviderScope
  models/classification_result.dart
  providers/classifier_provider.dart   # Riverpod Notifier + ImagePicker glue
  services/cifar10_classifier.dart     # TFLite init, preprocess, postprocess
  screens/
    homescreen.dart        # OnboardingGate, ClassificationScreen, ResultCard
    onboarding_screen.dart # 4-step onboarding
```

## Preprocessing & Postprocessing

Preprocess (Dart):
```dart
final resized = img.copyResize(srcImage, width: 32, height: 32, interpolation: img.Interpolation.linear);
final pixel = resized.getPixel(x, y);
final r = (pixel.r - 128).clamp(-128, 127);
final g = (pixel.g - 128).clamp(-128, 127);
final b = (pixel.b - 128).clamp(-128, 127);
```

Postprocess:
```dart
const outputScale = 0.11211809515953064;
const outputZeroPoint = -2;
final logits = rawOutput.map((q) => (q - outputZeroPoint) * outputScale).toList();
// softmax with max-logit stability, pick top class
```

No mean/std normalization. Keep RGB order.

## Limitations & Tips

- Model trained on 32×32 CIFAR-10 images. Real photos downscaled to 32×32 lose detail.
- Best results: centered object, plain background, good lighting, object fills 40-60% of frame.
- Per-class accuracy varies; birds/cats are hardest.

## Integration Checklist

- Model asset path: `assets/models/cnn_model_int8.tflite` ✓
- Assets declared in `pubspec.yaml` ✓
- Input size = 32 ✓
- int8 input buffer ✓
- Dequantize output with scale 0.112118 and zero_point -2 before softmax ✓
- Confidence threshold 0.45 ✓

