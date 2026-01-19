import 'package:flutter/material.dart';

class SubtitleTextWidget extends StatelessWidget {
  const SubtitleTextWidget({
    super.key,
    required this.label,
    //text koji prosledjume widgetu je label text koji se menja
    this.fontSize= 18,
    this.fontStyle=FontStyle.normal,
    this.fontWeight= FontWeight.normal,
    this.color,
    this.textDecoration=TextDecoration.none,
    this.maxLines,
    this.overflow,
    });
    final String label;
    final double fontSize;
    final FontStyle fontStyle;
    final FontWeight? fontWeight; //opciona promenljiva kad pozivamo ne moramo da je stavimo a i mozemo zato je ?
    final Color? color;
    final TextDecoration textDecoration;
    final int? maxLines;
    final TextOverflow? overflow;


  @override
  Widget build(BuildContext context) {
    return Text(
      label, //dobije iz druge kalse
      maxLines: maxLines,
      overflow: overflow,
      style: TextStyle(
        fontSize:  fontSize,
        fontStyle: fontStyle,
        fontWeight: fontWeight,
        color: color,
        decoration: textDecoration,
      )
    );
  }
}
