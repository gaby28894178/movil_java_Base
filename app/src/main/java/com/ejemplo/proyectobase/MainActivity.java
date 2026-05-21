package com.ejemplo.proyectobase;

import android.os.Bundle;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatActivity;

public class MainActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        TextView tvHola = findViewById(R.id.tvHolaMundo);
        tvHola.setText("Base Proyect  ");
    }
}
