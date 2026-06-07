# Origami Mentor

Ứng dụng Flutter hướng dẫn gấp giấy origami, lưu tiến độ cá nhân bằng SQLite local và có AI Coach hỗ trợ khi người dùng bị kẹt ở từng bước.

## Chức năng chính

- Danh sách kiểu gấp giấy: Hạc giấy, Thuyền, Hoa tulip, Ếch bật, Hộp masu, Rồng mini.
- Chi tiết từng mẫu gồm thông tin độ khó, thời gian, kích thước giấy và checklist 6 bước.
- Ghi nhận thành quả bản thân: thêm, sửa, xóa nhật ký hoàn thành trong SQLite.
- Profile: đăng nhập/đăng xuất bằng Gmail qua `google_sign_in`, có tài khoản demo để trình bày khi OAuth chưa cấu hình.
- Menu điều hướng: bottom navigation 4 tab và drawer phụ.
- Quản lý trạng thái: `AppState extends ChangeNotifier`, truyền dữ liệu mẫu gấp/tiến độ/thành quả giữa các màn hình.
- AI hướng dẫn: gọi Gemini API khi lưu API key trong Profile, tự fallback sang hướng dẫn cục bộ nếu chưa có key hoặc mất mạng.

## Business Rule

Ngoài CRUD nhật ký, app có rule hoàn thành:

- Phải tick đủ toàn bộ bước của mẫu gấp trước khi lưu thành quả.
- Rating tối thiểu 3 sao mới được tính hoàn thành.
- Huy hiệu tự mở theo số mẫu đã hoàn thành, số mẫu khác nhau, rating trung bình và mẫu độ khó cao.

## Cấu trúc quan trọng

- `lib/main.dart`: khởi tạo app và theme.
- `lib/models/origami_models.dart`: model dữ liệu.
- `lib/data/origami_database.dart`: SQLite schema, seed data và CRUD.
- `lib/state/app_state.dart`: state management, rule nghiệp vụ, login, AI.
- `lib/services/ai_coach_service.dart`: Gemini REST API và fallback local.
- `lib/ui/screens.dart`: toàn bộ màn hình nghiệp vụ.

## Chạy project

```bash
flutter pub get
flutter run
```

Kiểm tra code:

```bash
flutter analyze
flutter test
```

## Lưu ý cấu hình Gmail

Code đã tích hợp `google_sign_in`. Để đăng nhập Google thật trên Android, cần cấu hình OAuth client/SHA-1 theo package name hiện tại `com.example.origami`. Khi chưa cấu hình, có thể dùng nút "Dùng tài khoản demo Gmail" trong Profile để demo layout và luồng đăng xuất.

## Lưu ý AI

Vào Profile, nhập Gemini API key rồi lưu. Nếu không nhập key, màn hình AI Coach vẫn trả lời bằng rule local dựa trên mẫu gấp và các bước đang lưu trong SQLite.
