/// URL dasar backend Django REST Framework.
///
/// Bawaannya `http://10.0.2.2:8000`, yaitu alamat PC host yang bisa dijangkau
/// dari dalam emulator Android. Timpa lewat `--dart-define` sesuai platform:
///
/// - Chrome/web: `--dart-define=API_BASE_URL=http://localhost:8000`
/// - Backend yang sudah di-deploy:
///   `--dart-define=API_BASE_URL=https://salwa-alifia-myportofolio.pws.cs.ui.ac.id`
const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://10.0.2.2:8000',
);
