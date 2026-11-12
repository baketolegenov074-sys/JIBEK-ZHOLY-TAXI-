package kz.jibekzholy.passenger
import android.app.Activity
import android.os.Bundle
import android.graphics.Color
import android.widget.*
class MainActivity : Activity() {
 private val dark=Color.rgb(24,39,54)
 override fun onCreate(savedInstanceState:Bundle?) { super.onCreate(savedInstanceState)
  val scroll=ScrollView(this); val page=LinearLayout(this).apply { orientation=1; setPadding(22,28,22,24); setBackgroundColor(Color.rgb(247,248,250)) }
  page.addView(TextView(this).apply { text="ЖІБЕК ЖОЛЫ"; textSize=28f; setTextColor(dark); setTypeface(null,1) })
  page.addView(TextView(this).apply { text="Такси • Қалааралық • Жеткізу"; textSize=15f; setTextColor(Color.DKGRAY); setPadding(0,4,0,20) })
  val services=listOf("Қалалық такси","Қалааралық сапар","Сәлемдеме жеткізу","Эвакуатор","Жылжымалы шиномонтаж")
  val group=RadioGroup(this).apply { orientation=1 }; services.forEachIndexed { i,s -> group.addView(RadioButton(this).apply { text=s; id=100+i; textSize=16f; setTextColor(dark); isChecked=i==0 }) }; page.addView(group)
  val from=field("Қай жерден аламыз?"); val to=field("Қайда барамыз?"); val phone=field("Телефон нөмірі"); page.addView(from); page.addView(to); page.addView(phone)
  val button=Button(this).apply { text="ТАПСЫРЫС БЕРУ"; setTextColor(Color.WHITE); setBackgroundColor(dark) }; page.addView(button,LinearLayout.LayoutParams(-1,58))
  val status=TextView(this).apply { setTextColor(dark); setPadding(0,16,0,0) }; page.addView(status)
  button.setOnClickListener { if(from.text.isBlank() || to.text.isBlank() || phone.text.isBlank()) status.text="Мекенжай мен телефонды толық толтырыңыз." else status.text="Өтінім дайындалды: "+services[group.checkedRadioButtonId-100]+". Демонстрациялық нұсқа: серверге жіберу қосылмаған." }
  scroll.addView(page); setContentView(scroll)
 }
 private fun field(h:String)=EditText(this).apply { hint=h; textSize=16f; setSingleLine(true); setPadding(14,10,14,10); layoutParams=LinearLayout.LayoutParams(-1,54).apply { bottomMargin=10 } }
}
