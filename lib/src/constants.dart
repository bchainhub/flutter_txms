/// Network aliases mapping IDs and friendly names to number-pool names.
Map<String, String> aliases = {
  '1': 'xcb',
  'mainnet': 'xcb',
  'xcb': 'xcb',
  '3': 'xab',
  'devin': 'xab',
  'xab': 'xab',
};

/// Default phone numbers for each network and country.
final Map<String, Map<String, List<String>>> countries = {
  'xcb': {
    'global': ['+12019715152'],
    'us': ['+12019715152'],
  },
  'xab': {
    'global': ['+12014835939'],
    'us': ['+12014835939'],
  },
};
