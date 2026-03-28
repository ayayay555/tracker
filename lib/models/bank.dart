enum BankType { traditional, digital }

class Bank {
  final String id;
  final String name;
  final BankType type;
  final String? iconPath;

  const Bank({
    required this.id,
    required this.name,
    required this.type,
    this.iconPath,
  });

  static const List<Bank> phBanks = [
    // Traditional Banks
    Bank(id: 'bdo', name: 'BDO Unibank', type: BankType.traditional),
    Bank(id: 'landbank', name: 'LandBank', type: BankType.traditional),
    Bank(id: 'bpi', name: 'BPI', type: BankType.traditional),
    Bank(id: 'metrobank', name: 'Metrobank', type: BankType.traditional),
    Bank(id: 'chinabank', name: 'China Bank', type: BankType.traditional),
    Bank(id: 'rcbc', name: 'RCBC', type: BankType.traditional),
    Bank(id: 'securitybank', name: 'Security Bank', type: BankType.traditional),
    Bank(id: 'pnb', name: 'PNB', type: BankType.traditional),
    Bank(id: 'dbp', name: 'DBP', type: BankType.traditional),
    Bank(id: 'unionbank', name: 'UnionBank', type: BankType.traditional),
    
    // Digital Banks & Wallets
    Bank(id: 'gcash', name: 'GCash', type: BankType.digital),
    Bank(id: 'maya', name: 'Maya Bank', type: BankType.digital),
    Bank(id: 'gotyme', name: 'GoTyme Bank', type: BankType.digital),
    Bank(id: 'seabank', name: 'SeaBank', type: BankType.digital),
    Bank(id: 'grabpay', name: 'GrabPay', type: BankType.digital),
    Bank(id: 'cimb', name: 'CIMB Bank PH', type: BankType.digital),
    Bank(id: 'tonik', name: 'Tonik Bank', type: BankType.digital),
    Bank(id: 'uniondigital', name: 'UnionDigital Bank', type: BankType.digital),
    Bank(id: 'uno', name: 'UNO Digital Bank', type: BankType.digital),
    Bank(id: 'ofbank', name: 'OFBank', type: BankType.digital),
    Bank(id: 'ownbank', name: 'OwnBank', type: BankType.digital),
    Bank(id: 'netbank', name: 'Netbank', type: BankType.digital),
  ];
}
