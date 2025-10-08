import 'package:flutter/material.dart';


import '../../themes/colors.dart';
import '../container_decoration.dart';
import '../custom_button.dart';
import '../space.dart';

class ConfirmationWidget extends StatelessWidget {
  final String title, description;
  final bool? showCross, hideButton;
  final void Function() onConfirm;
  final void Function()? onCancel;
  const ConfirmationWidget({
    super.key,
    required this.title,
    required this.description,
    this.showCross = false,
    this.hideButton = false,
    required this.onConfirm,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: ContainerDecoration.decoration(
              color: primaryColor,
              bColor: primaryColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10.0),
                topRight: Radius.circular(10.0),
              ),
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Align(
                    alignment:
                        showCross! ? Alignment.centerLeft : Alignment.center,
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                      ).copyWith(fontSize: 16.0),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                if (showCross!)
                  Flexible(
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (hideButton == false)
            Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10.0),
                  bottomRight: Radius.circular(10.0),
                ),
                color: Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        description,
                        style: const TextStyle(fontSize: 15.0),
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: CancleButton(
                            buttonName: "CANCEL",
                            onClick: onCancel ??
                                () {
                                  Navigator.pop(context);
                                },
                          ),
                        ),
                        horizantalSpace(10.0),
                        Expanded(
                          child: SaveButton(
                            buttonName: "CONFIRM",
                            onClick: onConfirm,
                          ),
                        ),
                      ],
                    ),
                    verticalSpace(5.0),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
