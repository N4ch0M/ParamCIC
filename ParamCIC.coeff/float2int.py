#%% Bloque 1 Convierte los coeficientes a enteros y los guarda en un archivo
# ===========================================================================

# Importa librerías
import numpy as np
import matplotlib.pyplot as plt

f_clk = 50e6        # Frecuencia de reloj en Hz
N = 86              # Número de coeficientes (taps)
n = np.arange(N)    # Índices de los coeficientes
NBits = 16          # Número de bits para la representación
FileName = 'Filter3_Comp_x10.txt'  # Nombre del archivo de coeficientes

# ================================
# Lee el archivo con coeficientes 
# ================================
with open(FileName, 'r') as file:
    h = [float(line.strip()) for line in file.readlines()]

# Convertimos h a un array de NumPy para operaciones eficientes
h = np.array(h)

# ========================
# Escalado para hardware
# ========================
# Escalado por 2^(NBits-1) (para NBits bits)
scale_factor = 2**(NBits-1)
# Redondeo y conversión a enteros
h_scaled = np.round(h * scale_factor).astype(int)

print(h_scaled)

# ========================
# Muestra los resultados
# ========================
print("Coeficientes del filtro FIR (pasabajo):")
print(h)

print("\nCoeficientes escalados (multiplicados por 2^15):")
print(h_scaled)

# Mostrar los coeficientes en formato hexadecimal para Verilog
print("\nCoeficientes en formato hexadecimal para Verilog:")
for coeff in h_scaled:
    print(f"16'h{coeff:04X};")  # Formato hexadecimal de 4 dígitos

# ========================
# Respuesta en frecuencia
# ========================
# Calcula la respuesta en frecuencia usando la FFT
H_freq = np.fft.fft(h, 4096)  # 1024 puntos para mayor resolución
f = np.fft.fftfreq(4096, 1/f_clk)  # Frecuencias asociadas a los puntos FFT

# Magnitud y fase de la respuesta en frecuencia
H_mag = np.abs(H_freq)  # Magnitud
H_phase = np.angle(H_freq)  # Fase
H_mag_dB = 20 * np.log10(H_mag + 1e-20) 

# Grafica la magnitud de la respuesta en frecuencia en dB
plt.figure(figsize=(10, 6))

# Magnitud en dB
plt.subplot(2, 1, 1)
plt.plot(f[:2048], H_mag_dB[:2048])  # Solo se grafican las frecuencias positivas
plt.title("Respuesta en Frecuencia - Magnitud en dB")
plt.xlabel("Frecuencia (Hz)")
plt.ylabel("Magnitud (dB)")
plt.grid(True)
plt.ylim(-100, 10)

# Fase de la respuesta en frecuencia
plt.subplot(2, 1, 2)
plt.plot(f[:512], np.degrees(H_phase[:512]))  # Convertir fase a grados
plt.title("Respuesta en Frecuencia - Fase")
plt.xlabel("Frecuencia (Hz)")
plt.ylabel("Fase (grados)")
plt.grid(True)

# Gráficas
plt.tight_layout()
plt.show()

# ========================
# Graficar los coeficientes
# ========================
plt.figure(figsize=(8, 5))
plt.stem(n, h_scaled, basefmt=" ")
plt.title("Coeficientes del Filtro FIR Pasabajo Escalados", fontsize=14)
plt.xlabel("n (Índice de Coeficiente)", fontsize=12)
plt.ylabel("Valor de h[n] Escalado", fontsize=12)
plt.grid(True)
plt.xticks(n)  # Asegurar que los índices del coeficiente sean claramente visibles
plt.tight_layout()  # Ajustar el diseño para evitar recortes
plt.show()

# ==============================================
# Respuesta en frecuencia filtro cuantizado
# ==============================================
# Calcula la respuesta en frecuencia usando la FFT
H_freq = np.fft.fft(h_scaled, 4096)  # 1024 puntos para mayor resolución
f = np.fft.fftfreq(4096, 1/f_clk)  # Frecuencias asociadas a los puntos FFT

# Magnitud y fase de la respuesta en frecuencia
H_mag = np.abs(H_freq)  # Magnitud
H_phase = np.angle(H_freq)  # Fase
H_mag_dB = 20 * np.log10(H_mag + 1e-20) 

# Grafica la magnitud de la respuesta en frecuencia en dB
plt.figure(figsize=(10, 6))

# Magnitud en dB
plt.subplot(2, 1, 1)
plt.plot(f[:2048], H_mag_dB[:2048])  # Solo se grafican las frecuencias positivas
plt.title("Respuesta en Frecuencia - Magnitud en dB")
plt.xlabel("Frecuencia (Hz)")
plt.ylabel("Magnitud (dB)")
plt.grid(True)

# Fase de la respuesta en frecuencia
plt.subplot(2, 1, 2)
plt.plot(f[:512], np.degrees(H_phase[:512]))  # Convertir fase a grados
plt.title("Respuesta en Frecuencia - Fase")
plt.xlabel("Frecuencia (Hz)")
plt.ylabel("Fase (grados)")
plt.grid(True)

# Gráficas
plt.tight_layout()
plt.show()


# %% Bloque 2 Guardar en un archivo
file_name = f"..\\ParamCIC.srcs\\coeff_1\\M{len(h_scaled)}_coefficients.dat"

# ======================================================================
# Escribe los coeficientes en el archivo
# ======================================================================

with open(file_name, "w") as file:
    for coeff in h_scaled:
        # Convertir a complemento a dos (para 16 bits)
        if coeff < 0:
            coeff = (1 << NBits) + coeff  
        # Escribir en hexadecimal con salto de línea
        file.write(f"{coeff:04X}\n")  

# Mensaje de confirmación mejorado
print(f"✅ Coeficientes guardados en '{file_name}'")
print(f"📂 Ubicación: {file_name}")
print(f"🔢 Total de coeficientes: {len(h_scaled)}")


# %% Bloque 3 Verificación del filtro

# ======================================================================
# Genera una señal temporal (suma de señales de diferentes frecuencias)
# ======================================================================

# Vector de tiempo, 1 ms con frecuencia de muestreo f_clk
f_clk = 50e6        # Frecuencia de reloj
t = np.linspace(0, 0.01, int(0.01 * f_clk), endpoint=False)  

# Señal mixta con dos frecuencias
f1 = 2e5  
f2 = 10e6  
signal = 0.5 * np.sin(2 * np.pi * f1 * t) + 0.35 * np.sin(2 * np.pi * f2 * t)  

# Filtrar la señal usando el filtro FIR
filtered_signal = np.convolve(signal, h, mode='same')

# Graficar la señal original y la filtrada en el dominio del tiempo
plt.figure(figsize=(10, 6))

# Señal original
muestras = 1000;
plt.subplot(2, 2, 1)
plt.plot(t[:muestras], signal[:muestras])  # Se muestra una porción para mejor visualización
plt.title("Señal original en el dominio del tiempo")
plt.xlabel("Tiempo (s)")
plt.ylabel("Amplitud")
plt.grid(True)

# Señal filtrada
plt.subplot(2, 2, 2)
plt.plot(t[:muestras], filtered_signal[:muestras])
plt.title("Señal filtrada en el dominio del tiempo")
plt.xlabel("Tiempo (s)")
plt.ylabel("Amplitud")
plt.grid(True)

# Transformada de Fourier (FFT)
n_fft = 2**14  # Tamaño de la FFT
f_signal = np.fft.fft(signal, n_fft)
f_filtered_signal = np.fft.fft(filtered_signal, n_fft)

# Normalización y espectro unilateral
f_signal_mag = np.abs(f_signal[:n_fft//2]) / (n_fft//2)
f_filtered_signal_mag = np.abs(f_filtered_signal[:n_fft//2]) / (n_fft//2)

# Eje de frecuencias
f_axis = np.fft.fftfreq(n_fft, 1/f_clk)[:n_fft//2]  # Solo parte positiva

# Gráfico en el dominio de la frecuencia
plt.subplot(2, 2, 3)
plt.plot(f_axis, 20 * np.log10(f_signal_mag), label="Señal original")
plt.title("Espectro de la señal original")
plt.xlabel("Frecuencia (Hz)")
plt.ylabel("Magnitud (dB)")
plt.grid(True)
plt.ylim(-100, 0)

plt.subplot(2, 2, 4)
plt.plot(f_axis, 20 * np.log10(f_filtered_signal_mag), label="Señal filtrada")
plt.title("Espectro de la señal filtrada")
plt.xlabel("Frecuencia (Hz)")
plt.ylabel("Magnitud (dB)")
plt.grid(True)
plt.ylim(-100, 0)

plt.tight_layout()
plt.show()

# %% Bloque 4 Guarda para usar como señal en el testbench

# ======================================================================
# Escribe los datos a un archivo
# ======================================================================

# Acoto la señal
signal_limited = signal[:muestras]

# Escalado por 2^(NBits-1) (para NBits bits)
scale_factor = 2**(NBits-1)
# Redondeo y conversión a enteros
sig_scaled = np.round(signal_limited * scale_factor).astype(int)

sig_name = f"..\\FIR.srcs\\sim_1\\data\\input_signal.dat"

with open(sig_name, "w") as file:
    for data in sig_scaled:
        # Convertir a complemento a dos (para 16 bits)
        if data < 0:
            data = (1 << NBits) + data  
        # Escribir en hexadecimal con salto de línea
        file.write(f"{data:04X}\n")  

# Mensaje de confirmación mejorado
print(f"✅ Señal de entrada guardada en '{sig_name}'")
print(f"📂 Ubicación: {sig_name}")
print(f"🔢 Total de muestras: {len(sig_scaled)}")


# %%
