class MdlProductLimit
{
  MdlProductLimit({
    this.productTypeId = 0,
    this.product = '',
    this.productDescription = '',
    this.quantity = 0,
  });

  int productTypeId, quantity;
  String product, productDescription;

  factory MdlProductLimit.fromJson(Map<String, dynamic> json) => MdlProductLimit(
    productTypeId: json['productTypeId'],
    product: json['product'],
    productDescription: json['productDescription'],
    quantity: json['quantity'],
  );

  Map<String, dynamic> toJson() => {
    'productTypeId': productTypeId,
    'product': product,
    'productDescription': productDescription,
    'quantity': quantity,
  };
}