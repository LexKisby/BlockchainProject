part of page_classes;

class MyBody extends TextStyle {
  build(BuildContext context) {
    return TextStyle(
      color: Theme.of(context).textTheme.bodyText1.color,
    );
  }
}

class MyAccent extends TextStyle {
  build(BuildContext context) {
    return TextStyle(color: Theme.of(context).accentColor);
  }
}
