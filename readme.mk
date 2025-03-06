## 📌 รายละเอียดโปรเจ็กต์
โปรเจ็กต์นี้เป็นเกม **Rock Paper Scissors Lizard Spock** ที่ทำงานบน **Ethereum Blockchain**  
ใช้ **Commit-Reveal Scheme** เพื่อป้องกัน **Front-Running Attack** และมีการจัดการ **เวลาและการคืนเงิน**  
ระบบถูกออกแบบมาเพื่อให้แน่ใจว่า **เงินจะไม่ติดอยู่ในสัญญา** และ **รองรับกรณีที่ผู้เล่นไม่ครบ**  

---

## 📂 **โครงสร้างโปรเจ็กต์**
- `RPSLS.sol` → **Contract หลักของเกม**
- `CommitReveal.sol` → **ใช้ Commit-Reveal Scheme**
- `TimeUnit.sol` → **จัดการเวลาในเกม**

---

## 🔒 **1. ป้องกันเงินค้างใน Contract**
### **📌 ปัญหาที่อาจเกิดขึ้น**
- หากไม่มีระบบคืนเงิน **เงินจะติดอยู่ในสัญญา**
- ผู้เล่นอาจฝากเงินเข้าไป แต่เกมไม่สามารถเริ่มได้
- ผู้เล่นอาจออกจากเกมกลางคัน ทำให้ไม่มีใครชนะ  

### **✅ วิธีแก้ไข**
- ใช้ฟังก์ชันคืนเงินให้ผู้เล่นที่ไม่ได้เล่น  
- หากเกมไม่เริ่มหรือมีปัญหา ผู้เล่นสามารถขอคืนเงินได้  
- รีเซ็ตสถานะเกมทุกครั้งหลังจากจบแต่ละรอบ  

---

## 🕵️‍♂️ **2. ระบบ Commit-Reveal ป้องกันการโกง**
### **📌 ปัญหาที่อาจเกิดขึ้น**
- ถ้าเลือกตัวเลือกตรงๆ **ฝ่ายที่ Reveal ทีหลังสามารถโกงได้**
- ผู้เล่นอาจดูตัวเลือกของอีกฝ่ายแล้วเลือกให้ชนะ  

### **✅ วิธีแก้ไข**
- ใช้ **Commit-Reveal Scheme** โดยให้ผู้เล่น **commit ค่า hash ก่อน** และ reveal ทีหลัง  
- เมื่อ commit ผู้เล่นต้องสร้างค่า **random + choice** แล้วคำนวณ hash  
- เมื่อ reveal ผู้เล่นต้องส่งค่า random และ choice กลับมาเพื่อให้ระบบตรวจสอบว่า hash ตรงกัน  

---

## ⏳ **3. จัดการผู้เล่นที่ไม่ครบ**
### **📌 ปัญหาที่อาจเกิดขึ้น**
- หากมีแค่ 1 คนเข้าร่วมเกม **เกมจะค้างและไม่สามารถจบได้**
- ไม่มีระบบบังคับให้ผู้เล่นต้อง reveal ทำให้เกมอาจไม่จบ  

### **✅ วิธีแก้ไข**
- ใช้ระบบตรวจสอบเวลา หากผ่านไประยะหนึ่งแต่ไม่มีการ reveal เกมจะถูกยกเลิก  
- ผู้เล่นสามารถกดยกเลิกเกมและขอคืนเงินได้หากผู้เล่นอีกฝ่ายไม่เข้าร่วม  
- รีเซ็ตสถานะเกมหากเกมไม่สามารถดำเนินต่อได้  

---

## 🏆 **4. Reveal และตัดสินผู้ชนะ**
### **📌 กฎของเกม**
- ใช้กฎของ **Rock Paper Scissors Lizard Spock** ในการตัดสิน  
- ระบบจะรอจนกว่าผู้เล่นทั้งสองจะ reveal ค่าของตน  
- ใช้ **Modulo Math** เพื่อตัดสินว่าใครชนะตามกฎของเกม  

### **✅ วิธีแก้ไข**
- เมื่อผู้เล่นทั้งสอง reveal ระบบจะตรวจสอบค่าและตัดสินผลอัตโนมัติ  
- หากผู้เล่นไม่ reveal ในเวลาที่กำหนด ผู้เล่นอีกฝ่ายสามารถรับเงินคืนได้  
- หากเสมอ เงินจะถูกแบ่งให้ทั้งสองฝ่าย  

---

## 🚀 **ส่งโปรเจ็กต์**
1. **Push Code ขึ้น GitHub และตั้งเป็น Public Repo**
2. **ส่งลิงก์ไปที่ Google Classroom ภายในเวลาที่กำหนด**
3. **ตรวจสอบให้แน่ใจว่า Commit Timestamp อยู่ภายในเวลาส่งงาน**

---

## 📜 **สรุป**
✅ **ใช้ Commit-Reveal Scheme ป้องกันโกง**  
✅ **มีระบบคืนเงินเมื่อผู้เล่นไม่ครบ**  
✅ **Reveal ครบสองคน → ระบบตัดสินอัตโนมัติ**  
✅ **เงินไม่มีวันติดอยู่ใน Contract**  
✅ **โค้ดปลอดภัยและใช้งานได้จริงบน Ethereum**  
