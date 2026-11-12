package kz.jibekzholy.driver
import android.app.Activity
import android.os.Bundle
import android.graphics.Color
import android.widget.*
class MainActivity : Activity() {
 private val dark=Color.rgb(24,39,54)
 override fun onCreate(savedInstanceState:Bundle?) { super.onCreate(savedInstanceState)
  val scroll=ScrollView(this); val page=LinearLayout(this).apply { orientation=1; setPadding(22,28,22,24); setBackgroundColor(Color.rgb(247,248,250)) }
  page.addView(TextView(this).apply { text="ЖІБЕК ЖОЛЫ"; textSize=28f; setTextColor(dark); setTypeface(null,1) }); page.addView(TextView(this).apply { text="Жүргізуші кабинеті"; textSize=18f; setTextColor(Color.DKGRAY); setPadding(0,6,0,24) })
  val name=field("Аты-жөніңіз"); val phone=field("Телефон нөмірі"); val car=field("Көлік маркасы"); val plate=field("Мемлекеттік нөмір"); listOf(name,phone,car,plate).forEach { page.addView(it) }
  page.addView(TextView(this).apply { text="Қабылдайтын тапсырыстар"; textSize=18f; setTextColor(dark); setPadding(0,12,0,8) })
  listOf("Қалалық такси","Қалааралық сапар","Сәлемдеме жеткізу","Эвакуатор","Жылжымалы шиномонтаж").forEach { s -> page.addView(CheckBox(this).apply { text=s; setTextColor(dark) }) }
  val online=Switch(this).apply { text="Желіде / тапсырыс қабылдау"; setTextColor(dark); setPadding(0,18,0,18) }; page.addView(online)
  val save=Button(this).apply { text="ПРОФИЛЬДІ САҚТАУ"; setTextColor(Color.WHITE); setBackgroundColor(dark) }; page.addView(save,LinearLayout.LayoutParams(-1,58))
  val status=TextView(this).apply { setTextColor(dark); setPadding(0,16,0,0) }; page.addView(status)
  save.setOnClickListener { status.text=if(name.text.isBlank() || phone.text.isBlank() || car.text.isBlank()) "Аты-жөнін, телефонды және көлікті толтырыңыз." else "Профиль дайындалды. Сервер мен нақты тапсырыстар жүйесі әлі қосылмаған." }
  scroll.addView(page); setContentView(scroll)
 }
 private fun field(h:String)=EditText(this).apply { hint=h; textSize=16f; setSingleLine(true); setPadding(14,10,14,10); layoutParams=LinearLayout.LayoutParams(-1,54).apply { bottomMargin=10 } }
}
