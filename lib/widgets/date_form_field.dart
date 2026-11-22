import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/utils/formatters.dart';

/// Kolom formulir untuk memilih satu tanggal lewat [showDatePicker].
///
/// Dibuat sebagai [FormField]<[DateTime]> (bukan sekadar tombol) agar menjadi
/// bagian dari [Form]: `FormState.validate()` ikut memeriksanya, `reset()`
/// mengosongkannya, dan pesan kesalahan tampil di bawah kolom seperti
/// [TextFormField]. Pengguna tidak mengetik tanggal, sehingga format yang salah
/// tidak mungkin terjadi; aturan lain (wajib, urutan tanggal) diberikan lewat
/// `validator`.
class DateFormField extends FormField<DateTime> {
  DateFormField({
    super.key,
    required String label,
    required DateTime firstDate,
    required DateTime lastDate,
    DateTime? pickerStartDate,
    ValueChanged<DateTime?>? onChanged,
    super.validator,
    super.onSaved,
    super.initialValue,
    super.enabled,
    super.autovalidateMode,
  }) : super(
         builder: (FormFieldState<DateTime> field) {
           final isEnabled = field.widget.enabled;

           Future<void> pickDate() async {
             // initialDate wajib berada di antara firstDate dan lastDate.
             final suggested =
                 field.value ?? pickerStartDate ?? DateTime.now();
             final initial = suggested.isBefore(firstDate)
                 ? firstDate
                 : (suggested.isAfter(lastDate) ? lastDate : suggested);

             final picked = await showDatePicker(
               context: field.context,
               initialDate: initial,
               firstDate: firstDate,
               lastDate: lastDate,
               helpText: label,
               cancelText: 'Batal',
               confirmText: 'Pilih',
             );

             // Batal ditekan: pertahankan nilai lama.
             if (picked != null) {
               field.didChange(picked);
               onChanged?.call(picked);
             }
           }

           return InkWell(
             borderRadius: BorderRadius.circular(5.0),
             onTap: isEnabled ? pickDate : null,
             child: InputDecorator(
               isEmpty: field.value == null,
               decoration: InputDecoration(
                 labelText: label,
                 hintText: 'Pilih tanggal',
                 enabled: isEnabled,
                 errorText: field.errorText,
                 // Pesan kesalahan boleh lebih dari satu baris agar tidak
                 // terpotong "..." pada layar sempit.
                 errorMaxLines: 3,
                 suffixIcon: const Icon(Icons.calendar_month),
                 border: OutlineInputBorder(
                   borderRadius: BorderRadius.circular(5.0),
                 ),
               ),
               child: field.value == null
                   ? null
                   : Text(formatDate(field.value!)),
             ),
           );
         },
       );
}
