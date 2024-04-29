import matplotlib.pyplot as plt
import numpy as np
import tkinter as tk
from tkinter import Scale
import sys
import os
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg


def resource_path(relative_path):
    base_path = getattr(sys, '_MEIPASS', os.path.dirname(os.path.abspath(__file__)))
    return os.path.join(base_path, relative_path)


def on_closing():
    root.quit()
    root.destroy()
    
def map_value(x, in_min, in_max, out_min, out_max):
    return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min

def calculate_turbo_curve(input_normalized_rpm, peak_turbo_boost, peak_turbo_decayment_boost, 
                          turbo_decayment_point, max_turbo_boost_point_max, max_turbo_boost_point_min, 
                          max_turbo_boost_point_min_prct, max_turbo_boost_point_max_prct, boost_starting_point):
    
    rpm = input_normalized_rpm
    peakturboboostpoint = max_turbo_boost_point_max
    turbodecaymentpeakpoint = turbo_decayment_point
    maxdecayboost = peak_turbo_decayment_boost
    booststartingpoint = boost_starting_point
    rpm_3000 = max_turbo_boost_point_min
    rpm_4500 = max_turbo_boost_point_max
    boost_3000 = max_turbo_boost_point_min_prct
    boost_4500 = max_turbo_boost_point_max_prct
    
    a = (boost_4500 - boost_3000) / ((rpm_4500 - rpm_3000) ** 2)
    b = boost_3000 - a * (rpm_3000 - booststartingpoint) ** 2
    
    c = (peak_turbo_decayment_boost - boost_4500) / (turbo_decayment_point - rpm_4500)
    d = peak_turbo_decayment_boost - c * turbo_decayment_point
    
    boost_factor = 0
    if rpm < boost_starting_point:
        boost_factor = 0
    elif rpm >= boost_starting_point and rpm <= max_turbo_boost_point_max:
        boost_factor = a * (rpm - boost_starting_point) ** 2 + b
    else:
        boost_factor = c * rpm + d
        if boost_factor > peak_turbo_decayment_boost:
            boost_factor = peak_turbo_decayment_boost

    peakValueInOriginalModel = a * (max_turbo_boost_point_max - boost_starting_point) ** 2 + b 

    scalingFactor = peak_turbo_boost / peakValueInOriginalModel

    return boost_factor * scalingFactor

def plot_turbo_curve(params):
    (peak_turbo_boost, peak_turbo_decayment_boost, turbo_decayment_point,
     max_turbo_boost_point_max, max_turbo_boost_point_min, 
     max_turbo_boost_point_min_prct, max_turbo_boost_point_max_prct, 
     boost_starting_point) = params

    rpm_values = np.linspace(0.0, 1.0, 100)
    turbo_curve = [calculate_turbo_curve(rpm, map_value(peak_turbo_boost,20,100,20,85), peak_turbo_decayment_boost,
                                         turbo_decayment_point, max_turbo_boost_point_max,
                                         max_turbo_boost_point_min, max_turbo_boost_point_min_prct,
                                         max_turbo_boost_point_max_prct, boost_starting_point) for rpm in rpm_values]

    plt.clf()
    plt.plot(rpm_values, turbo_curve, label='Turbo Curve')
    plt.xlabel('Normalized RPM')
    plt.ylabel('Turbo Boost Power Increase (%)')
    plt.title('Turbo Boost Curve')
    plt.grid(True)
    plt.legend()
    canvas.draw()

def update_values():
    params = (peak_turbo_boost_scale.get(), map_value(peak_turbo_decayment_boost_scale.get(),20,100,20,85),
              turbo_decayment_point_scale.get(), max_turbo_boost_point_max_scale.get(),
              max_turbo_boost_point_min_scale.get(), max_turbo_boost_point_min_prct_scale.get(),
              max_turbo_boost_point_max_prct_scale.get(), boost_starting_point_scale.get())
    plot_turbo_curve(params)

icon_path = resource_path('icon.ico')
root = tk.Tk()
root.title("C.H.A.S.E.R Turbo Curve Adjuster | x.com/Legacy_DMC ")
root.iconbitmap(icon_path)


root.grid_rowconfigure(0, weight=1)
root.grid_columnconfigure(0, weight=1)
root.grid_columnconfigure(1, weight=3)


frame_sliders = tk.Frame(root)
frame_sliders.grid(row=0, column=0, sticky="nsew")

frame_plot = tk.Frame(root)
frame_plot.grid(row=0, column=1, sticky="nsew")


peak_turbo_boost_scale = Scale(frame_sliders, from_=20, to=100, resolution=1, label='Compressor Size (MM)', orient='horizontal', command=lambda x: update_values())
peak_turbo_boost_scale.set(40)
peak_turbo_boost_scale.pack(fill='x', expand=True)


peak_turbo_decayment_boost_scale = Scale(frame_sliders, from_=0, to=100, resolution=1, label='Peak Turbo Decayment Boost (%)', orient='horizontal', command=lambda x: update_values())
peak_turbo_decayment_boost_scale.set(35)
peak_turbo_decayment_boost_scale.pack(fill='x', expand=True)



turbo_decayment_point_scale = Scale(frame_sliders, from_=0, to=1, resolution=0.01, label='Turbo Decayment Point (Normalized RPM)', orient='horizontal', command=lambda x: update_values())
turbo_decayment_point_scale.set(0.75)
turbo_decayment_point_scale.pack(fill='x', expand=True)



max_turbo_boost_point_max_scale = Scale(frame_sliders, from_=0, to=1, resolution=0.01, label='Max Turbo Boost Point (Normalized RPM)', orient='horizontal', command=lambda x: update_values())
max_turbo_boost_point_max_scale.set(0.5833)
max_turbo_boost_point_max_scale.pack(fill='x', expand=True)


max_turbo_boost_point_min_scale = Scale(frame_sliders, from_=0, to=1, resolution=0.01, label='Min Turbo Boost Point (Normalized RPM)', orient='horizontal', command=lambda x: update_values())
max_turbo_boost_point_min_scale.set(0.333)
max_turbo_boost_point_min_scale.pack(fill='x', expand=True)


max_turbo_boost_point_min_prct_scale = Scale(frame_sliders, from_=0, to=100, resolution=1, label='Max Turbo Boost Min Point Boost (%)', orient='horizontal', command=lambda x: update_values())
max_turbo_boost_point_min_prct_scale.set(10)
max_turbo_boost_point_min_prct_scale.pack(fill='x', expand=True)


max_turbo_boost_point_max_prct_scale = Scale(frame_sliders, from_= 0, to=100, resolution=1, label='Max Turbo Boost Max Point Boost (%)', orient='horizontal', command=lambda x: update_values())
max_turbo_boost_point_max_prct_scale.set(30)
max_turbo_boost_point_max_prct_scale.pack(fill='x', expand=True)


boost_starting_point_scale = Scale(frame_sliders, from_=0, to=1, resolution=0.01, label='Boost Starting Point (Normalized RPM)', orient='horizontal', command=lambda x: update_values())
boost_starting_point_scale.set(0.25)
boost_starting_point_scale.pack(fill='x', expand=True)


fig, ax = plt.subplots()
canvas = FigureCanvasTkAgg(fig, master=frame_plot)
canvas_widget = canvas.get_tk_widget()
canvas_widget.pack(fill=tk.BOTH, expand=True)

update_values()  # Initial plot

root.protocol("WM_DELETE_WINDOW", on_closing)

root.mainloop()