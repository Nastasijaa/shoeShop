import 'package:flutter/material.dart';
import 'package:shoeshop/services/assets_menager.dart';
import 'package:shoeshop/widgets/subtitle_text.dart';

class MyAppFunctions {
  static Future<void> imagePickerDialog({
    required BuildContext context,
    required Future<void> Function() cameraFCT,
    required Future<void> Function() galleryFCT,
    required VoidCallback removeFCT,
  }) async {
    await showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Camera"),
                onTap: () async {
                  Navigator.pop(ctx);
                  await cameraFCT();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Gallery"),
                onTap: () async {
                  Navigator.pop(ctx);
                  await galleryFCT();
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text("Remove"),
                onTap: () {
                  Navigator.pop(ctx);
                  removeFCT();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  static Future<void> showErrorOrWarningDialog({
    required BuildContext context,
    required String subtitle,
    bool isError = true,
    required VoidCallback fct,
  }) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                isError
                    ? "${AssetsMenager.imagePath}/warning.png"
                    : "${AssetsMenager.imagePath}/caution.png",
                height: 60,
                width: 60,
              ),
              const SizedBox(height: 16.0),
              Center(
                child: SubtitleTextWidget(
                  label: subtitle,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Visibility(
                    visible: !isError,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const SubtitleTextWidget(
                        label: "Cancel",
                        color: Colors.green,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      if (!isError) {
                        fct();
                      }
                    },
                    child: const SubtitleTextWidget(
                      label: "OK",
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  static void showGuestOnlyMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Gost korisnici ne mogu da lajkuju, dodaju u korpu ili kupuju. Uloguj se.",
        ),
      ),
    );
  }
}
