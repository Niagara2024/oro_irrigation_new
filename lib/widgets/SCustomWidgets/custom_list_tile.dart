import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'custom_drop_down.dart';
import 'custom_time_picker.dart';

class CustomSwitchTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool showSubTitle;
  final bool value;
  final Function(bool) onChanged;
  final Widget? icon;
  final bool showCircleAvatar;
  final BorderRadius? borderRadius;

  const CustomSwitchTile({super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.icon,
    this.borderRadius,
    this.subtitle,
    this.showSubTitle = false,
    this.showCircleAvatar = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.zero,
      ),
      subtitle: showSubTitle ? Text(subtitle ?? '') : null,
      contentPadding: showSubTitle ? const EdgeInsets.symmetric(horizontal: 10) : const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      leading: showCircleAvatar ? CircleAvatar(backgroundColor: Theme.of(context).colorScheme.secondary, child: icon) : null,
      title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}

class CustomTimerTile extends StatelessWidget {
  final String subtitle;
  final bool showSubTitle;
  final String? subtitle2;
  final String initialValue;
  final Widget? leading;
  final Function(String) onChanged;
  final IconData? icon;
  final bool isSeconds;
  final bool isNative;
  final Color? tileColor;
  final BorderRadius? borderRadius;
  final bool is24HourMode;

  const CustomTimerTile({
    Key? key,
    required this.subtitle,
    required this.initialValue,
    required this.onChanged,
    this.icon,
    this.borderRadius,
    required this.isSeconds,
    this.is24HourMode = false,
    this.tileColor,
    this.leading,
    this.isNative = false,
    this.showSubTitle = false,
    this.subtitle2
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.zero,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      leading: leading ??
          CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              child: Icon(icon, color: Colors.black)),
      title: Text(subtitle, style: Theme.of(context).textTheme.bodyLarge),
      subtitle: showSubTitle ? Text(subtitle ?? '') : null,
      trailing: isNative
          ? InkWell(
        child: Text(initialValue, style: Theme.of(context).textTheme.bodyMedium),
        onTap: () async {
          TimeOfDay? selectedTime;

          if (initialValue != '') {
            try {
              List<String> timeParts = initialValue.split(' ');

              if (timeParts.length == 2) {
                String time = timeParts[0];
                String period = timeParts[1];

                List<String> timeDigits = time.split(':');
                if (timeDigits.length == 2) {
                  int hour = int.parse(timeDigits[0]);
                  int minute = int.parse(timeDigits[1]);

                  if (!is24HourMode) {
                    if (period.toLowerCase() == 'pm' && hour < 12) {
                      hour += 12;
                    } else if (period.toLowerCase() == 'am' && hour == 12) {
                      hour = 0;
                    }
                  }

                  selectedTime = TimeOfDay(hour: hour, minute: minute);
                } else {
                  print("Invalid time format");
                }
              } else {
                print("Invalid time format");
              }
            } catch (e) {
              print("Error parsing time: $e");
            }
          } else {
            selectedTime = TimeOfDay.fromDateTime(DateTime.now());
          }

          selectedTime = await showTimePicker(
            context: context,
            initialTime: selectedTime ?? TimeOfDay.now(),
            builder: (BuildContext context, Widget? child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: is24HourMode),
                child: child!,
              );
            },
          );

          if (selectedTime != null) {
            String formattedTime = is24HourMode
                ? "${selectedTime.hour}:${selectedTime.minute}"
                : selectedTime.format(context);

            onChanged(formattedTime);
          }
        },
      )
          : CustomTimePicker(
        initialTime: initialValue,
        onChanged: onChanged,
        isSeconds: isSeconds,
        is24HourMode: is24HourMode,
      ),
      tileColor: tileColor,
    );
  }
}

class CustomTextFormTile extends StatelessWidget {
  final String subtitle;
  final String hintText;
  final String? errorText;
  final String? initialValue;
  final TextEditingController? controller;
  final Function(String) onChanged;
  final IconData? icon;
  final BorderRadius? borderRadius;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final Color? tileColor;
  final bool trailing;
  final String? trailingText;

  const CustomTextFormTile({super.key,
    required this.subtitle,
    required this.hintText,
    this.controller,
    required this.onChanged,
    this.icon,
    this.borderRadius,
    this.keyboardType,
    this.inputFormatters,
    this.errorText,
    this.initialValue,
    this.tileColor,
    this.trailing = false,
    this.trailingText
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.zero,
      ),
      contentPadding: const EdgeInsets.all(8),
      leading: CircleAvatar(backgroundColor: Theme.of(context).colorScheme.secondary, child: Icon(icon, color: Colors.black)),
      title: Text(subtitle, style: Theme.of(context).textTheme.bodyLarge),
      subtitle: errorText != null ?Text(errorText!, style: const TextStyle(color: Colors.red, fontSize: 12),) : null,
      trailing: SizedBox(
        width: 80,
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: initialValue,
                textAlign: TextAlign.center,
                controller: controller,
                keyboardType: keyboardType,
                inputFormatters: inputFormatters,
                decoration: InputDecoration(
                  hintText: hintText,
                  contentPadding: const EdgeInsets.symmetric(vertical: 5),
                  // errorText: errorText
                ),
                onChanged: onChanged,
              ),
            ),
            if (trailing) Text(trailingText ?? "", style: Theme.of(context).textTheme.bodyMedium,),
          ],
        ),
      ),
      tileColor: tileColor,
    );
  }
}

class CustomCheckBoxListTile extends StatelessWidget {
  final String subtitle;
  final bool value;
  final Function(bool?) onChanged;
  final IconData? icon;
  final dynamic content;
  final Widget? image;
  final bool showCircleAvatar;
  final BorderRadius? borderRadius;

  const CustomCheckBoxListTile({super.key,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.icon,
    this.borderRadius,
    this.image,
    this.content,
    this.showCircleAvatar = true
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.zero,
      ),
      contentPadding: const EdgeInsets.all(8),
      leading: showCircleAvatar ? CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        child: content is IconData
            ? Icon(content, color: Colors.black)
            : Text(
          content,
          style: TextStyle(
              color: Colors.black,
              fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize
          ),
        ),
      ) : null,
      title: Text(subtitle, style: Theme.of(context).textTheme.bodyLarge),
      trailing: Checkbox(
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}

class CustomTile extends StatelessWidget {
  final dynamic content;
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final BorderRadius? borderRadius;
  final Color? tileColor;
  final TextAlign? textAlign;
  final TextStyle? titleColor;
  final bool showCircleAvatar;
  final bool showSubTitle;
  final EdgeInsets contentPadding;

  const CustomTile({
    Key? key,
    required this.title,
    this.trailing,
    this.borderRadius,
    this.content,
    this.tileColor,
    this.textAlign,
    this.titleColor,
    this.leading,
    this.showCircleAvatar = true,
    this.showSubTitle = false,
    this.subtitle,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.zero,
      ),
      subtitle: showSubTitle ? Text(subtitle ?? '') : null,
      contentPadding: showSubTitle ? const EdgeInsets.symmetric(horizontal: 10) : contentPadding,
      leading: showCircleAvatar ? CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        child: content is IconData
            ? Icon(content, color: Colors.black)
            : Text(
          content,
          style: TextStyle(
              color: Colors.black,
              fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize
          ),
        ),
      ) : null,
      title: Text(title, style: titleColor ?? Theme.of(context).textTheme.bodyLarge, textAlign: textAlign,),
      trailing: trailing,
      tileColor: tileColor,
    );
  }
}

class CustomDropdownTile extends StatelessWidget {
  final dynamic content;
  final String title;
  final String? subtitle;
  final bool showSubTitle;
  final double width;
  final Widget? trailing;
  final BorderRadius? borderRadius;
  final Color? tileColor;
  final TextAlign? textAlign;
  final TextStyle? titleColor;
  final List<String> dropdownItems;
  final String selectedValue;
  final bool includeNoneOption;
  final void Function(String?) onChanged;
  final bool showCircleAvatar;

  const CustomDropdownTile({
    Key? key,
    required this.title,
    this.trailing,
    this.borderRadius,
    this.content,
    this.tileColor,
    this.textAlign,
    this.titleColor,
    required this.dropdownItems,
    required this.selectedValue,
    required this.onChanged,
    this.includeNoneOption = true,
    this.showCircleAvatar = true,
    this.subtitle,
    this.showSubTitle = false,
    this.width = 130,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.zero,
      ),
      subtitle: showSubTitle ? Text(subtitle ?? '') : null,
      contentPadding: showSubTitle ? const EdgeInsets.symmetric(horizontal: 10) : const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      leading: showCircleAvatar ? CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        child: content is IconData
            ? Icon(content, color: Colors.black)
            : Text(
          content,
          style: TextStyle(
            color: Colors.black,
            fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
          ),
        ),
      ) : null,
      title: Text(title, style: titleColor ?? Theme.of(context).textTheme.bodyLarge, textAlign: textAlign),
      trailing: SizedBox(
        width: width,
        child: CustomDropdownWidget(
          dropdownItems: dropdownItems,
          selectedValue: selectedValue,
          onChanged: onChanged,
          includeNoneOption: includeNoneOption,
        ),
      ),
      tileColor: tileColor,
    );
  }
}
