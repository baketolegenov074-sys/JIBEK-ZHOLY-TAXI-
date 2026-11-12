package kz.jibekzholy.driver

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Color
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.location.Location
import android.location.LocationManager
import android.os.Bundle
import android.provider.MediaStore
import android.view.Gravity
import android.widget.*
import android.view.View
import android.net.Uri
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat

class MainActivity : Activity() {
 private val navy=Color.rgb(16,39,69); private val gold=Color.rgb(244,184,35)
 private val teal=Color.rgb(0,137,123); private val ink=Color.rgb(30,42,56)
 private val muted=Color.rgb(105,116,128); private val paper=Color.rgb(245,247,250)
 private lateinit var page:LinearLayout; private lateinit var status:TextView
 private var selfieDone=false; private var carDone=false; private var docDone=false
 private var pendingCamera=""; private var online=false
 private val cameraCode=701; private val locationCode=702
 private lateinit var name:EditText; private lateinit var phone:EditText
 private lateinit var car:EditText; private lateinit var plate:EditText
 private lateinit var locationText:TextView
 override fun onCreate(savedInstanceState:Bundle?){super.onCreate(savedInstanceState)
  window.statusBarColor=navy;window.navigationBarColor=Color.WHITE
  window.decorView.systemUiVisibility=View.SYSTEM_UI_FLAG_LIGHT_NAVIGATION_BAR
  val sc=ScrollView(this).apply{fillViewport=true;clipToPadding=false;isVerticalScrollBarEnabled=false};page=LinearLayout(this).apply{orientation=1;setPadding(dp(16),dp(16),dp(16),dp(36));setBackgroundColor(paper)}
  sc.addView(page);setContentView(sc);render()
 }
 private fun render(){
  page.removeAllViews()
  val header=LinearLayout(this).apply{orientation=1;setPadding(dp(18),dp(22),dp(18),dp(22));background=rounded(navy,20)}
  header.addView(txt("ЖІБЕК ЖОЛЫ",25f,Color.WHITE,true))
  header.addView(txt("Жүргізуші кабинеті",16f,Color.rgb(218,226,235),false).apply{setPadding(0,dp(5),0,0)})
  page.addView(header)
  val summary=card();summary.addView(txt("Жұмысқа шығу",19f,navy,true))
  status=txt(if(online)"Сіз желідесіз" else "Сіз желіден тыссыз",15f,if(online)teal else muted,true)
  summary.addView(status)
  val toggle=Switch(this).apply{text="Тапсырыс қабылдауға дайынмын";isChecked=online;setOnCheckedChangeListener{_,checked->
   if(checked && !hasLocation()){online=false;isChecked=false;status.text="Орналасу рұқсатын беріңіз";requestLocation()}
   else {online=checked;status.text=if(checked)"GPS рұқсат берілді. Сервер қосылғанда тапсырыстар келеді." else "Сіз желіден тыссыз";saveState()}
  }}
  summary.addView(toggle);summary.addView(txt("Желіге қосылу GPS рұқсатымен ғана іске қосылады. Қолданба фондық бақылауды жасырын жүргізбейді.",12f,muted,false))
  page.addView(summary)
  val location=card();location.addView(txt("Орналасу және GPS",18f,navy,true))
  locationText=txt("Орналасу әлі алынған жоқ",14f,muted,false);location.addView(locationText)
  location.addView(actionButton("ОРНАЛАСҚАН ЖЕРІМДІ АНЫҚТАУ"){requestLocation()})
  page.addView(location)
  val profile=card();profile.addView(txt("Жүргізуші профилі",18f,navy,true))
  name=field("Аты-жөніңіз");phone=field("Телефон нөмірі",android.text.InputType.TYPE_CLASS_PHONE)
  car=field("Көлік маркасы және моделі");plate=field("Мемлекеттік нөмір")
  profile.addView(label("Аты-жөніңіз"));profile.addView(name)
  profile.addView(label("Телефон"));profile.addView(phone)
  profile.addView(label("Көлік"));profile.addView(car)
  profile.addView(label("Мемлекеттік нөмір"));profile.addView(plate)
  val pref=getSharedPreferences("driver_profile",Context.MODE_PRIVATE)
  name.setText(pref.getString("name",""));phone.setText(pref.getString("phone",""))
  car.setText(pref.getString("car",""));plate.setText(pref.getString("plate",""))
  profile.addView(actionButton("ПРОФИЛЬДІ САҚТАУ"){
   if(name.text.isBlank()||phone.text.isBlank()||car.text.isBlank()||plate.text.isBlank())toast("Барлық профиль өрістерін толтырыңыз")
   else {pref.edit().putString("name",name.text.toString()).putString("phone",phone.text.toString()).putString("car",car.text.toString()).putString("plate",plate.text.toString()).apply();toast("Профиль осы телефонда сақталды")}
  })
  page.addView(profile)
  val checks=card();checks.addView(txt("Фото және құжат бақылауы",18f,navy,true))
  checks.addView(txt("Тексеру үшін камера арқылы жаңа фото түсіріңіз. Қазір фото телефонда ғана қалады; серверлік тексеру мен бет сәйкестендіру әлі қосылмаған.",13f,muted,false))
  checks.addView(checkRow("Жүргізушінің селфиі",selfieDone){capture("selfie")})
  checks.addView(checkRow("Көліктің фотосы",carDone){capture("car")})
  checks.addView(checkRow("Құжат фотосы",docDone){capture("doc")})
  page.addView(checks)
  val safety=card();safety.addView(txt("Қабылдайтын қызметтер",18f,navy,true))
  listOf("Қалалық такси","Қалааралық сапар","Сәлемдеме жеткізу","Эвакуатор","Жылжымалы шиномонтаж").forEach{v->safety.addView(CheckBox(this).apply{text=v;setTextColor(ink)})}
  page.addView(safety)
  val note=card();note.addView(txt("Маңызды",17f,navy,true))
  note.addView(txt("Құжат пен фотоны нақты тексеру, тапсырысты алу, жолаушымен байланыс, төлем және табыс есебі орталық серверді және оператор аккаунттарын қосуды талап етеді. Бұл экран олар қосылғандай болып көрсетпейді.",13f,muted,false))
  page.addView(note)
 }
 private fun checkRow(title:String,done:Boolean,action:()->Unit):LinearLayout{
  val row=LinearLayout(this).apply{orientation=0;gravity=Gravity.CENTER_VERTICAL;setPadding(0,dp(12),0,dp(6))}
  val text=txt(title+" — "+if(done)"Фото түсірілді" else "Өтпеген",14f,if(done)teal else ink,true)
  row.addView(text,LinearLayout.LayoutParams(0,-2,1f));row.addView(actionButton(if(done)"ҚАЙТА ТҮСІРУ" else "ТҮСІРУ",action))
  return row
 }
 private fun capture(kind:String){
  if(ContextCompat.checkSelfPermission(this,Manifest.permission.CAMERA)!=PackageManager.PERMISSION_GRANTED){
   pendingCamera=kind;ActivityCompat.requestPermissions(this,arrayOf(Manifest.permission.CAMERA),cameraCode);return
  }
  launchCamera(kind)
 }
 private fun launchCamera(kind:String){pendingCamera=kind
  try{startActivityForResult(Intent(MediaStore.ACTION_IMAGE_CAPTURE),cameraCode)}
  catch(e:Exception){toast("Камераны ашу мүмкін болмады")}
 }
 override fun onActivityResult(requestCode:Int,resultCode:Int,data:Intent?){super.onActivityResult(requestCode,resultCode,data)
  if(requestCode==cameraCode && resultCode==RESULT_OK){
   val photo=data?.extras?.get("data") as? Bitmap
   if(photo==null){toast("Фото алынбады. Қайта түсіріңіз");return}
   when(pendingCamera){"selfie"->selfieDone=true;"car"->carDone=true;"doc"->docDone=true}
   toast("Фото алынды. Бұл әлі ресми тексеруден өткенін білдірмейді.");render()
  }
 }
 private fun requestLocation(){
  if(!hasLocation()){ActivityCompat.requestPermissions(this,arrayOf(Manifest.permission.ACCESS_FINE_LOCATION,Manifest.permission.ACCESS_COARSE_LOCATION),locationCode);return}
  try{
   val lm=getSystemService(LOCATION_SERVICE) as LocationManager
   val providers=lm.getProviders(true);var best:Location?=null
   for(p in providers){val l=lm.getLastKnownLocation(p);if(l!=null&&(best==null||l.accuracy<best!!.accuracy))best=l}
   locationText.text=if(best!=null)"Координаттар: %.5f, %.5f".format(best!!.latitude,best!!.longitude) else "GPS қосулы, бірақ соңғы координат табылмады. Ашық жерде қайта көріңіз."
  }catch(e:SecurityException){locationText.text="GPS рұқсаты берілмеген"}
 }
 private fun hasLocation()=ContextCompat.checkSelfPermission(this,Manifest.permission.ACCESS_FINE_LOCATION)==PackageManager.PERMISSION_GRANTED||ContextCompat.checkSelfPermission(this,Manifest.permission.ACCESS_COARSE_LOCATION)==PackageManager.PERMISSION_GRANTED
 override fun onRequestPermissionsResult(requestCode:Int,permissions:Array<out String>,grantResults:IntArray){super.onRequestPermissionsResult(requestCode,permissions,grantResults)
  if(grantResults.isNotEmpty()&&grantResults[0]==PackageManager.PERMISSION_GRANTED){
   if(requestCode==locationCode)requestLocation()
   if(requestCode==cameraCode)launchCamera(pendingCamera)
  }else toast("Рұқсат берілмеді")
 }
 private fun saveState(){getSharedPreferences("driver_profile",Context.MODE_PRIVATE).edit().putBoolean("online",online).apply()}
 private fun field(h:String,type:Int=android.text.InputType.TYPE_CLASS_TEXT)=EditText(this).apply{hint=h;inputType=type;textSize=16f;includeFontPadding=true;minHeight=dp(56);setSingleLine(true);setTextColor(ink);gravity=Gravity.CENTER_VERTICAL;background=rounded(Color.rgb(248,250,252),10,Color.rgb(218,225,232));setPadding(dp(14),dp(12),dp(14),dp(12));layoutParams=LinearLayout.LayoutParams(-1,dp(58)).apply{bottomMargin=dp(10)}}
 private fun label(s:String)=txt(s,13f,muted,true).apply{includeFontPadding=true;minHeight=dp(28);gravity=Gravity.CENTER_VERTICAL;setPadding(0,dp(6),0,dp(4));setLineSpacing(dp(2),1f)}
 private fun card()=LinearLayout(this).apply{orientation=1;setPadding(dp(16),dp(16),dp(16),dp(16));background=rounded(Color.WHITE,17);elevation=dp(2).toFloat();layoutParams=LinearLayout.LayoutParams(-1,-2).apply{topMargin=dp(12)}}
 private fun txt(s:String,size:Float,color:Int,bold:Boolean)=TextView(this).apply{text=s;textSize=size;setTextColor(color);includeFontPadding=true;setLineSpacing(dp(2),1f);if(bold)setTypeface(typeface,Typeface.BOLD)}
 private fun actionButton(s:String,action:()->Unit)=TextView(this).apply{text=s;textSize=12f;gravity=Gravity.CENTER;setTextColor(navy);typeface=Typeface.DEFAULT_BOLD;background=rounded(gold,10);setPadding(dp(12),dp(12),dp(12),dp(12));setOnClickListener{action()}}
 private fun rounded(color:Int,r:Int,stroke:Int?=null)=GradientDrawable().apply{setColor(color);cornerRadius=dp(r).toFloat();if(stroke!=null)setStroke(dp(1),stroke)}
 private fun dp(v:Int)=(v*resources.displayMetrics.density).toInt()
 private fun toast(s:String)=Toast.makeText(this,s,Toast.LENGTH_LONG).show()
}