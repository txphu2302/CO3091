# CO3091 - Đồ án Thiết kế luận lý

## Giới thiệu
Bán hàng tự động là một hình thức bán hàng rất phổ biến ở các nước phát triển. Lợi ích của
bán hàng tự động là tiết kiệm được chi phí trong kinh doanh khi không cần phải thuê nhân viên
bán hàng cũng như tìm kiếm mặt bằng thuê cửa hàng. Ngoài ra, người mua hàng có thể được mua
với giá tốt nhất. Nguyên tắc hoạt động cơ bản của máy bán hàng tự động là lưu trữ lượng sản
phẩm với giá thành cho từng sản phẩm. Khi có người mua hàng, tùy thuộc vào sản phẩm được
chọn, máy sẽ tính ra lượng tiền tương ứng cần thanh toán. Sau đó, người mua hàng phải trả tiền
và nhận sản phẩm, đồng thời máy sẽ trả tiền thừa cho người mua hàng (nếu có) và kết thúc giao
dịch.

## Chức năng

### 1. **Chế độ**
- Hệ thống có **2 chế độ**: **User** và **Admin**.
- Chuyển đổi chế độ thông qua switch được chỉ định.

### 2. **Hiển thị thông tin**
- Hệ thống sẽ hiển thị:
  - Chế độ hiện tại (User/Admin).
  - Số lượng và giá cả của từng mặt hàng.
  - Số tiền hiện tại của người dùng.
- **Màn hình LCD 16x2**: Hiển thị thông tin về chế độ, số lượng và giá cả mặt hàng.
- **Led 7 đoạn**: Hiển thị số tiền hiện tại của người dùng.

### 3. **Nạp tiền dành cho người dùng**
- Người dùng có thể nạp tiền vào máy thông qua nút nhấn được chỉ định.

### 4. **Lựa chọn các mặt hàng**
- Người dùng có thể chọn mặt hàng mong muốn thông qua các switch được chỉ định.

### 5. **Cập nhật số lượng và giá thành của hàng hóa**
- Quản trị viên có thể thay đổi thông tin hàng hóa:
  - Tăng số lượng mặt hàng.
  - Tăng hoặc giảm giá thành của mặt hàng.
- Thực hiện các thay đổi thông qua nút bấm được chỉ định.

### 6. **Cách thức thanh toán**
- Sau khi người dùng nạp tiền vào máy:
  1. Hệ thống hiển thị số tiền người dùng đã nạp.
  2. Kiểm tra số lượng hàng hóa hiện có.
  3. So sánh số tiền nạp với giá cả mặt hàng muốn mua.
  4. Hoàn lại tiền thừa (nếu có) cho người dùng.


 
