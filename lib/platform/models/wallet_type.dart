
enum WalletType {
  Card("card"),
  Momo("momo"),
  Gratis("hubtel"),
  GMoney("GMoney"),
  Zeepay("Zeepay"),
  Hubtel("hubtel");

  const WalletType(this.optionValue);

  final String optionValue;
}