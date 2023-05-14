const kFirebaseUrl = "still-chassis-382314-default-rtdb.firebaseio.com";
const kFirebaseFile = '/shopping-list.json';
final kDatabaseUrlList = Uri.https(kFirebaseUrl, kFirebaseFile);
Uri kDatabaseUrl(final String? id) {
  if (id == 'null') {
    return kDatabaseUrlList;
  } else {
    final kDatabaseUrlItem = Uri.https(kFirebaseUrl, "/shopping-list/$id.json");
    return kDatabaseUrlItem;
  }
}
