import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'custom_drop_down.dart';
import 'custom_time_picker.dart';

class CustomSwitchTile extends StatelessWidget {
  final String subtitle;
  final bool value;
  final Function(bool) onChanged;
  final IconData? icon;
  final BorderRadius? borderRadius;

  const CustomSwitchTile({super.key,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.icon,
    this.borderRadius,
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
      trailing: Switch(
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}

class CustomTimerTile extends StatelessWidget {
  final String subtitle;
  final String initialValue;
  final Widget? leading;
  final Function(String) onChanged;
  final IconData? icon;
  final bool isSeconds;
  final Color? tileColor;
  final BorderRadius? borderRadius;
  final bool? is24HourMode;

  const CustomTimerTile({super.key,
    required this.subtitle,
    required this.initialValue,
    required this.onChanged,
    this.icon,
    this.borderRadius,
    required this.isSeconds,
    this.is24HourMode,
    this.tileColor,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.zero,
      ),
      contentPadding: const EdgeInsets.all(8),
      leading: leading ?? CircleAvatar(backgroundColor: Theme.of(context).colorScheme.secondary, child: Icon(icon, color: Colors.black)),
      title: Text(subtitle, style: Theme.of(context).textTheme.bodyLarge),
      trailing: CustomTimePicker(
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
      tileColor: tileColor,
    );
  }
}

Color getRandomColor() {
  final Random random = Random();
  return Color.fromARGB(
    255,
    random.nextInt(256),
    random.nextInt(256),
    random.nextInt(256),
  );
}
class CustomCheckBoxListTile extends StatelessWidget {
  final String subtitle;
  final bool value;
  final Function(bool?) onChanged;
  final IconData? icon;
  final BorderRadius? borderRadius;

  const CustomCheckBoxListTile({super.key,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.icon,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.zero,
      ),
      contentPadding: const EdgeInsets.all(8),
      leading: CircleAvatar(backgroundColor: Theme.of(context).colorScheme.secondary,child: Icon(icon, color: Colors.black)),
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
  final String subtitle;
  final Widget? leading;
  final Widget? trailing;
  final BorderRadius? borderRadius;
  final Color? tileColor;
  final TextAlign? textAlign;
  final TextStyle? titleColor;

  const CustomTile({
    Key? key,
    required this.subtitle,
    this.trailing,
    this.borderRadius,
    this.content,
    this.tileColor,
    this.textAlign,
    this.titleColor,
    this.leading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.zero,
      ),
      contentPadding: const EdgeInsets.all(8),
      leading: leading ?? CircleAvatar(
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
      ),
      title: Text(subtitle, style: titleColor ?? Theme.of(context).textTheme.bodyLarge, textAlign: textAlign,),
      trailing: trailing,
      tileColor: tileColor,
    );
  }
}

class CustomDropdownTile extends StatelessWidget {
  final dynamic content;
  final String subtitle;
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
    required this.subtitle,
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
  }) : super(key: key);

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
            fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
          ),
        ),
      ) : null,
      title: Text(subtitle, style: titleColor ?? Theme.of(context).textTheme.bodyLarge, textAlign: textAlign),
      trailing: SizedBox(
        width: 130,
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
