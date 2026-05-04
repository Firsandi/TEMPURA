class ApiConstants {
  static const String baseUrl = 'http://10.0.2.2:8080';
  
  // Supabase Config (Ganti dengan punya kamu dari Dashboard -> Settings -> API)
  static const String supabaseUrl = 'https://lllvgxdrsdnohuwogrog.supabase.co'; 
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxsbHZneGRyc2Rub2h1d29ncm9nIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzc3MjczNTIsImV4cCI6MjA5MzMwMzM1Mn0.puockEO7ne8ik2yJUj62Aob-tDuemhEYP3dXIrnXESM';

  static const String loginEndpoint = '/auth/login';
  static const String forgotPasswordEndpoint = '/auth/forgot-password';
  static const String resetPasswordEndpoint = '/auth/reset-password';
}
