package kz.jibekzholy.passenger

import android.app.Activity
import android.os.Bundle
import android.graphics.Color
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.text.InputType
import android.view.Gravity
import android.view.View
import android.widget.*

class MainActivity : Activity() {
    private val navy = Color.rgb(22,  forty(), 56)
    private val teal = Color.rgb(0, 137, 123)
    private val ink = Color.rgb(29, 41, 55)
    private val muted = Color.rgb(100, 110, 120)
    private val pageColor = Color.rgb(245, 247, 250)

    private fun forty() = 40

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        window.statusBarColor = pageColor
        window.navigationBarColor = pageColor
        window.decorView.systemUiVisibility = View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR or View.SYSTEM_UI_FLAG_LIGHT_NAVIGATION_BAR

        val scroll = ScrollView(this).apply {
            isFillViewport = true
            setBackgroundColor(pageColor)
            clipToPadding = false
        }
        val page = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(dp(20), dp(22), dp(20), dp(28))
        }

        page.addView(label("ЖІБЕК ЖОЛЫ", 30f, navy, true))
        page.addView(label("Такси • Қалааралық • Жеткізу", 16f, muted, false).apply {
            setPadding(0, dp(4), 0, dp(20))
        })

        val card = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            background = rounded(Color.WHITE, 18)
            setPadding(dp(18), dp(16), dp(18), dp(18))
            elevation = dp(2).toFloat()
        }
        card.addView(label("Қызмет түрін таңдаңыз", 18f, ink, true).apply {
            setPadding(0, 0, 0, dp(10))
        })

        val services = listOf(
            "Қалалық такси",
            "Қалааралық сапар",
            "Сәлемдеме жеткізу",
            "Эвакуатор",
            "Жылжымалы шиномонтаж"
        )
        val group = RadioGroup(this).apply { orientation = RadioGroup.VERTICAL }
        services.forEachIndexed { index, service ->
            group.addView(RadioButton(this).apply {
                id = 100 + index
                text = service
                textSize = 17f
                setTextColor(ink)
                buttonTintList = android.content.res.ColorStateList(
                    arrayOf(intArrayOf(android.R.attr.state_checked), intArrayOf()),
                    intArrayOf(teal, muted)
                )
                minHeight = dp(48)
                gravity = Gravity.CENTER_VERTICAL
                isChecked = index == 0
            }, RadioGroup.LayoutParams(-1, -2))
        }
        card.addView(group)
        card.addView(label("Қай жерден алып кету керек?", 15f, ink, true).apply {
            setPadding(0, dp(18), 0, dp(7))
        })
        val from = input("Мекенжайды енгізіңіз")
        card.addView(from)
        card.addView(label("Қайда барасыз?", 15f, ink, true).apply {
            setPadding(0, dp(13), 0, dp(7))
        })
        val to = input("Баратын мекенжайды енгізіңіз")
        card.addView(to)
        card.addView(label("Телефон нөмірі", 15f, ink, true).apply {
            setPadding(0, dp(13), 0, dp(7))
        })
        val phone = input("+7 ___ ___ __ __").apply {
            inputType = InputType.TYPE_CLASS_PHONE
        }
        card.addView(phone)

        page.addView(card)
        val button = TextView(this).apply {
            text = "ТАПСЫРЫС БЕРУ"
            textSize = 17f
            typeface = Typeface.DEFAULT_BOLD
            setTextColor(Color.WHITE)
            gravity = Gravity.CENTER
            background = rounded(teal, 14)
            setPadding(dp(12), dp(17), dp(12), dp(17))
            elevation = dp(2).toFloat()
        }
        val buttonParams = LinearLayout.LayoutParams(-1, -2).apply {
            topMargin = dp(18)
        }
        page.addView(button, buttonParams)

        val status = label("", 14f, ink, false).apply {
            setPadding(dp(4), dp(12), dp(4), 0)
        }
        page.addView(status)

        button.setOnClickListener {
            val selected = group.checkedRadioButtonId - 100
            when {
                from.text.isBlank() || to.text.isBlank() || phone.text.isBlank() ->
                    status.text = "Мекенжайлар мен телефон нөмірін толтырыңыз."
                selected !in services.indices ->
                    status.text = "Қызмет түрін таңдаңыз."
                else ->
                    status.text = "Өтінім толтырылды: ${services[selected]}. Бұл әзірге сынақ нұсқасы — тапсырыс серверге жіберілмейді."
            }
        }

        scroll.addView(page)
        setContentView(scroll)
    }

    private fun label(textValue: String, size: Float, color: Int, bold: Boolean): TextView =
        TextView(this).apply {
            text = textValue
            textSize = size
            setTextColor(color)
            if (bold) setTypeface(typeface, Typeface.BOLD)
            includeFontPadding = true
        }

    private fun input(hintText: String): EditText = EditText(this).apply {
        hint = hintText
        textSize = 16f
        setTextColor(ink)
        setHintTextColor(muted)
        setSingleLine(true)
        minHeight = dp(54)
        background = rounded(Color.rgb(248, 250, 252), 11, Color.rgb(218, 225, 232))
        setPadding(dp(14), dp(10), dp(14), dp(10))
        layoutParams = LinearLayout.LayoutParams(-1, -2)
    }

    private fun rounded(color: Int, radius: Int, stroke: Int? = null): GradientDrawable =
        GradientDrawable().apply {
            setColor(color)
            cornerRadius = dp(radius).toFloat()
            if (stroke != null) setStroke(dp(1), stroke)
        }

    private fun dp(value: Int): Int = (value * resources.displayMetrics.density).toInt()
}
