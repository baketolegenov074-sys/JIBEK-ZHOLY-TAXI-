package kz.jibekzholy.passenger
import android.app.Activity
import android.os.Bundle
import android.content.Context
import android.Manifest
import android.content.pm.PackageManager
import android.location.Location
import android.location.LocationManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import android.graphics.Color
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.text.InputType
import android.view.Gravity
import android.view.View
import android.widget.*

class MainActivity : Activity() {
 private val navy=Color.rgb(16,39,69); private val gold=Color.rgb(244,184,35)
 private val teal=Color.rgb(0,137,123); private val ink=Color.rgb(30,42,56)
 private val muted=Color.rgb(105,116,128); private val paper=Color.rgb(245,247,250)
 private lateinit var root:FrameLayout; private lateinit var content:LinearLayout
 private lateinit var drawer:LinearLayout; private var pageName="home"
 override fun onCreate(savedInstanceState:Bundle?) { super.onCreate(savedInstanceState)
  window.statusBarColor=navy; window.navigationBarColor=Color.WHITE
  window.decorView.systemUiVisibility=View.SYSTEM_UI_FLAG_LIGHT_NAVIGATION_BAR
  root=FrameLayout(this); content=LinearLayout(this).apply{orientation=1;setBackgroundColor(paper)}
  root.addView(content,FrameLayout.LayoutParams(-1,-1)); buildDrawer(); home(); setContentView(root)
 }
 private fun buildDrawer(){
  drawer=LinearLayout(this).apply{orientation=1;setPadding(dp(18),dp(42),dp(18),dp(20));setBackgroundColor(Color.WHITE);elevation=dp(18).toFloat();visibility=View.GONE}
  root.addView(drawer,FrameLayout.LayoutParams((resources.displayMetrics.widthPixels*.82f).toInt(),-1,Gravity.START))
  drawer.addView(txt("ЖІБЕК ЖОЛЫ",25f,navy,true))
  drawer.addView(txt("Жолаушы кабинеті",14f,muted,false).apply{setPadding(0,dp(5),0,dp(28))})
  menu("⌂","Басты бет"){closeDrawer();home()}
  menu("▤","Менің тапсырыстарым"){closeDrawer();orders()}
  menu("●","Профиль"){closeDrawer();profile()}
  menu("?","Көмек"){closeDrawer();help()}
  drawer.addView(Space(this),LinearLayout.LayoutParams(1,0,1f))
  drawer.addView(txt("Қала: Шымкент",14f,muted,true))
 }
 private fun menu(icon:String,title:String,action:()->Unit){
  val r=LinearLayout(this).apply{orientation=0;gravity=Gravity.CENTER_VERTICAL;setPadding(dp(8),dp(15),dp(8),dp(15));isClickable=true;setOnClickListener{action()}}
  r.addView(txt(icon,22f,teal,true),LinearLayout.LayoutParams(dp(42),-2));r.addView(txt(title,17f,ink,true));drawer.addView(r)
 }
 private fun openDrawer(){drawer.visibility=View.VISIBLE;drawer.bringToFront()}
 private fun closeDrawer(){drawer.visibility=View.GONE}
 private fun shell(title:String,sub:String?=null){
  pageName=title;content.removeAllViews()
  val top=LinearLayout(this).apply{orientation=0;gravity=Gravity.CENTER_VERTICAL;setPadding(dp(16),dp(12),dp(16),dp(12));setBackgroundColor(navy)}
  top.addView(txt("☰",27f,Color.WHITE,true).apply{gravity=Gravity.CENTER;setOnClickListener{openDrawer()}},LinearLayout.LayoutParams(dp(48),dp(48)))
  val t=LinearLayout(this).apply{orientation=1;setPadding(dp(8),0,0,0)}
  t.addView(txt(title,19f,Color.WHITE,true));if(sub!=null)t.addView(txt(sub,12f,Color.LTGRAY,false));top.addView(t);content.addView(top)
  val sc=ScrollView(this).apply{isFillViewport=true}
  val b=LinearLayout(this).apply{orientation=1;setPadding(dp(18),dp(18),dp(18),dp(28))}
  sc.addView(b);content.addView(sc,LinearLayout.LayoutParams(-1,0,1f));content.tag=b
 }
 private fun body()=content.tag as LinearLayout
 private fun home(){
  shell("ЖІБЕК ЖОЛЫ","Сапарыңызды оңай жоспарлаңыз")
  val b=body();val welcome=card()
  welcome.addView(txt("Қайда барамыз?",25f,navy,true))
  welcome.addView(txt("Қызметті таңдаңыз. Әр қызмет жеке экранда ашылады.",14f,muted,false))
  b.addView(welcome);b.addView(txt("ҚЫЗМЕТТЕР",13f,muted,true).apply{setPadding(dp(3),dp(22),0,dp(10))})
  tile("🚕","Қалалық такси","Шымкент ішінде"){service("city")}
  tile("🛣","Қалааралық сапар","Қазақстан қалалары арасында"){service("intercity")}
  tile("📦","Сәлемдеме жеткізу","Құжаттар мен жүктер"){service("parcel")}
  tile("🚛","Эвакуатор","Көлікті жеткізу"){service("tow")}
  tile("🛞","Жылжымалы шиномонтаж","Маман сізге келеді"){service("tire")}
 }
 private fun tile(icon:String,title:String,desc:String,act:()->Unit){
  val c=card().apply{orientation=0;gravity=Gravity.CENTER_VERTICAL;isClickable=true;setOnClickListener{act()}}
  c.addView(txt(icon,29f,teal,true),LinearLayout.LayoutParams(dp(52),-2))
  val words=LinearLayout(this).apply{orientation=1;layoutParams=LinearLayout.LayoutParams(0,-2,1f)}
  words.addView(txt(title,17f,ink,true));words.addView(txt(desc,13f,muted,false))
  c.addView(words);c.addView(txt("›",28f,teal,true))
  body().addView(c,LinearLayout.LayoutParams(-1,-2).apply{bottomMargin=dp(10)})
 }
 private fun service(type:String){
  val titles=mapOf("city" to "Қалалық такси","intercity" to "Қалааралық сапар","parcel" to "Сәлемдеме жеткізу","tow" to "Эвакуатор","tire" to "Жылжымалы шиномонтаж")
  val title=titles[type] ?: "Тапсырыс";shell(title,"Тапсырыс мәліметтерін толтырыңыз")
  val b=body();val c=card();c.addView(txt(title,21f,navy,true))
  val fields=mutableListOf<Pair<String,EditText>>()
  fun field(label:String,hint:String,kind:Int=InputType.TYPE_CLASS_TEXT){
   c.addView(txt(label,14f,ink,true).apply{setPadding(0,dp(14),0,dp(5))})
   val e=edit(hint,kind);c.addView(e);fields.add(Pair(label,e))
  }
  when(type){
   "city"->{field("Қай жерден алып кету керек?","Мекенжай");field("Қайда барасыз?","Баратын мекенжай");field("Жолаушылар саны","Мысалы: 2",InputType.TYPE_CLASS_NUMBER)}
   "intercity"->{field("Қай қаладан?","Мысалы: Шымкент");field("Қай қалаға?","Мысалы: Алматы");field("Жолға шығатын күн","Күні / айы / жылы");field("Жолаушылар саны","Мысалы: 3",InputType.TYPE_CLASS_NUMBER);field("Жүк туралы","Чемодан, сөмке...")}
   "parcel"->{field("Алып кету мекенжайы","Жіберуші мекенжайы");field("Жеткізу мекенжайы","Алушы мекенжайы");field("Алушының аты-жөні","Аты-жөні");field("Алушының телефоны","+7",InputType.TYPE_CLASS_PHONE);field("Сәлемдеме сипаттамасы","Не жеткізу керек?")}
   "tow"->{field("Көлік тұрған жер","Нақты мекенжай");field("Қайда жеткізу керек?","Жеткізу мекенжайы");field("Көлік маркасы","Мысалы: Toyota");field("Мәселе","Ақауды жазыңыз");field("Телефон нөмірі","+7",InputType.TYPE_CLASS_PHONE)}
   "tire"->{field("Қызмет мекенжайы","Қай жерге келу керек?");field("Көлік маркасы","Мысалы: Hyundai");field("Қандай жұмыс керек?","Дөңгелек ауыстыру, жамау");field("Телефон нөмірі","+7",InputType.TYPE_CLASS_PHONE)}
  }
  field("Сіздің телефон нөміріңіз","+7 ___ ___ __ __",InputType.TYPE_CLASS_PHONE);b.addView(c)
  if(fields.isNotEmpty()) b.addView(linkButton("◎ GPS АРҚЫЛЫ АЛҒАШҚЫ МЕКЕНЖАЙДЫ АНЫҚТАУ"){requestPickupLocation(fields[0].second)})
  val msg=txt("",14f,teal,true).apply{setPadding(dp(4),dp(12),dp(4),0)};b.addView(msg)
  b.addView(button("ТАПСЫРЫСТЫ РӘСІМДЕУ"){
   val missing=fields.firstOrNull{it.second.text.toString().trim().isEmpty()}
   if(missing!=null)msg.text="«"+missing.first+"» өрісін толтырыңыз."
   else{
    val details=fields.joinToString(" • "){it.first+": "+it.second.text.toString().trim()}
    val id=System.currentTimeMillis().toString().takeLast(7)
    val line=id+"|"+title+"|"+details+"|Сақталды"
    val prefs=getSharedPreferences("jibek_orders",Context.MODE_PRIVATE)
    val old=prefs.getString("orders","") ?: ""
    prefs.edit().putString("orders",if(old.isBlank())line else line+"\n"+old).apply()
    msg.text="Өтінім №"+id+" осы телефонда сақталды. Жүргізушіге жіберу сервер қосылғаннан кейін іске қосылады."
    fields.forEach{it.second.isEnabled=false}
   }
  })
  b.addView(linkButton("← Қызметтерге оралу"){home()})
 }

 private fun requestPickupLocation(target:EditText){
  if(ContextCompat.checkSelfPermission(this,Manifest.permission.ACCESS_FINE_LOCATION)!=PackageManager.PERMISSION_GRANTED &&
     ContextCompat.checkSelfPermission(this,Manifest.permission.ACCESS_COARSE_LOCATION)!=PackageManager.PERMISSION_GRANTED){
   ActivityCompat.requestPermissions(this,arrayOf(Manifest.permission.ACCESS_FINE_LOCATION,Manifest.permission.ACCESS_COARSE_LOCATION),802)
   pendingPickup=target;return
  }
  try{
   val lm=getSystemService(LOCATION_SERVICE) as LocationManager
   var best:Location?=null
   for(provider in lm.getProviders(true)){
    val loc=lm.getLastKnownLocation(provider)
    if(loc!=null && (best==null || loc.accuracy<best!!.accuracy)) best=loc
   }
   if(best!=null) target.setText("%.5f, %.5f".format(best!!.latitude,best!!.longitude))
   else Toast.makeText(this,"GPS қосулы, бірақ координат табылмады. Ашық жерде қайталап көріңіз.",Toast.LENGTH_LONG).show()
  }catch(e:SecurityException){Toast.makeText(this,"Орналасу рұқсаты жоқ",Toast.LENGTH_SHORT).show()}
 }
 private var pendingPickup:EditText?=null
 override fun onRequestPermissionsResult(requestCode:Int,permissions:Array<out String>,grantResults:IntArray){
  super.onRequestPermissionsResult(requestCode,permissions,grantResults)
  if(requestCode==802 && grantResults.isNotEmpty() && grantResults[0]==PackageManager.PERMISSION_GRANTED){
   pendingPickup?.let{requestPickupLocation(it)};pendingPickup=null
  }
 }

 private fun orders(){
  shell("Менің тапсырыстарым","Сақталған өтінімдер")
  val b=body();val raw=getSharedPreferences("jibek_orders",Context.MODE_PRIVATE).getString("orders","") ?: ""
  if(raw.isBlank()){val c=card();c.addView(txt("Әзірге тапсырыс жоқ",19f,navy,true));c.addView(txt("Басты беттен қызметті таңдап, өтінім толтырыңыз.",14f,muted,false));b.addView(c)}
  else raw.split("\n").filter{it.isNotBlank()}.forEach{line->
   val p=line.split("|",limit=4);val c=card()
   c.addView(txt("№ "+p.getOrElse(0){""},13f,teal,true))
   c.addView(txt(p.getOrElse(1){"Тапсырыс"},18f,navy,true))
   c.addView(txt(p.getOrElse(2){""},13f,ink,false))
   c.addView(txt("Күйі: "+p.getOrElse(3){"Сақталды"},13f,muted,true))
   b.addView(c,LinearLayout.LayoutParams(-1,-2).apply{bottomMargin=dp(10)})
  }
 }
 private fun profile(){
  shell("Профиль","Жолаушы деректері");val c=card()
  val n=edit("Аты-жөніңіз");val p=edit("+7 ___ ___ __ __",InputType.TYPE_CLASS_PHONE)
  c.addView(txt("Аты-жөніңіз",14f,ink,true));c.addView(n)
  c.addView(txt("Телефон",14f,ink,true));c.addView(p);body().addView(c)
  val pref=getSharedPreferences("jibek_profile",Context.MODE_PRIVATE)
  n.setText(pref.getString("name",""));p.setText(pref.getString("phone",""))
  body().addView(button("САҚТАУ"){pref.edit().putString("name",n.text.toString()).putString("phone",p.text.toString()).apply();Toast.makeText(this,"Профиль сақталды",Toast.LENGTH_SHORT).show()})
 }
 private fun help(){
  shell("Көмек","Ақпарат")
  val c=card();c.addView(txt("Жібек Жолы такси қызметі",20f,navy,true))
  c.addView(txt("Бұл нұсқада өтінімдер телефон ішінде сақталады. Диспетчерге жіберу, жүргізушімен байланыс, GPS карта және төлем сервер қосылғаннан кейін іске қосылады.",15f,ink,false))
  body().addView(c)
 }
 private fun card()=LinearLayout(this).apply{orientation=1;setPadding(dp(16),dp(16),dp(16),dp(16));background=rounded(Color.WHITE,17);elevation=dp(2).toFloat()}
 private fun txt(s:String,size:Float,color:Int,bold:Boolean)=TextView(this).apply{text=s;textSize=size;setTextColor(color);if(bold)setTypeface(typeface,Typeface.BOLD);includeFontPadding=true}
 private fun edit(h:String,kind:Int=InputType.TYPE_CLASS_TEXT)=EditText(this).apply{hint=h;inputType=kind;textSize=16f;setTextColor(ink);setHintTextColor(muted);minHeight=dp(52);setSingleLine(kind!=InputType.TYPE_CLASS_TEXT);background=rounded(Color.rgb(248,250,252),10,Color.rgb(218,225,232));setPadding(dp(12),dp(9),dp(12),dp(9))}
 private fun button(title:String,act:()->Unit)=TextView(this).apply{text=title;textSize=16f;typeface=Typeface.DEFAULT_BOLD;gravity=Gravity.CENTER;setTextColor(navy);background=rounded(gold,13);setPadding(dp(14),dp(17),dp(14),dp(17));setOnClickListener{act()};layoutParams=LinearLayout.LayoutParams(-1,-2).apply{topMargin=dp(16)}}
 private fun linkButton(title:String,act:()->Unit)=TextView(this).apply{text=title;textSize=15f;gravity=Gravity.CENTER;setTextColor(teal);setPadding(dp(10),dp(18),dp(10),dp(12));setOnClickListener{act()}}
 private fun rounded(color:Int,radius:Int,stroke:Int?=null)=GradientDrawable().apply{setColor(color);cornerRadius=dp(radius).toFloat();if(stroke!=null)setStroke(dp(1),stroke)}
 private fun dp(v:Int)=(v*resources.displayMetrics.density).toInt()
 override fun onBackPressed(){if(drawer.visibility==View.VISIBLE)closeDrawer() else if(pageName!="ЖІБЕК ЖОЛЫ")home() else super.onBackPressed()}
}