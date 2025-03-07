/// Network aliases mapping friendly names to network IDs
const Map<String, int> aliases = {
  'mainnet': 1,
  'devin': 3,
};

/// Default phone numbers for each network and country
final Map<String, Map<String, List<String>>> countries = {
  '1': {
    'global': ['+12019715152'],
    'us': ['+12019715152'],
  },
  '3': {
    'global': ['+12014835939'],
    'us': ['+12014835939'],
  },
};
