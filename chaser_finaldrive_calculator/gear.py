import tkinter as tk
from tkinter import Label, Entry, Button, StringVar, Frame, N, E, S, W

def calculate_topspeed():
    try:
        topspeed = float(top_speed_entry.get())
        gearratio = [float(gear_entries[i].get()) for i in range(10) if gear_entries[i].get()]
        gearammount = len(gearratio) - 1
        
        if gearammount not in gtagratiotables:
            result_label.config(text="Error: Gear amount not supported!")
            return
        
        finaldrive = 0.0
        topspeedgear = 0
        while topspeedgear < topspeed:
            finaldriveadjustable = topspeed * finaldrive
            calculatedtopspeed = gtagratiotables[gearammount][gearammount] * finaldriveadjustable / gearratio[-1]
            topspeedgear = (calculatedtopspeed * 0.9) / gtagratiotables[gearammount][gearammount]
            finaldrive += 0.001

        result_label.config(text=f"Final Drive: {finaldrive:.3f}, Top Speed Gear: {topspeedgear:.2f}, Ammount of Gears: {gearammount:.0f}")
    except ValueError as e:
        result_label.config(text=f"Error: {str(e)}")

# Create the main window
root = tk.Tk()
root.title("Top Speed and Gear Ratio Calculator")

# Define data structures
gtagratiotables = {
    9: [-3.333, 3.333, 1.849, 1.253, 0.935, 0.767, 0.692, 0.686, 0.749, 0.9],
    8: [-3.333, 3.333, 1.898, 1.321, 1.011, 0.851, 0.788, 0.803, 0.9],
    7: [-3.333, 3.333, 1.934, 1.372, 1.070, 0.918, 0.867, 0.9],
    6: [-3.333, 3.333, 1.949, 1.392, 1.095, 0.946, 0.9],
    5: [-3.333, 3.333, 1.924, 1.358, 1.054, 0.9],
    4: [-3.333, 3.333, 1.826, 1.222, 0.9],
    3: [-3.333, 3.333, 1.567, 0.9],
    2: [-3.333, 3.333, 0.9],
    1: [-3.333, 0.9],
    0: [-3.333]
}

# Create UI elements
top_speed_label = Label(root, text="Top Speed:")
top_speed_entry = Entry(root)

gear_labels = []
gear_entries = []
for i in range(10):
    label_text = "Reverse Gear:" if i == 0 else f"Gear {i}:"
    gear_labels.append(Label(root, text=label_text))
    gear_entries.append(Entry(root))

calculate_button = Button(root, text="Calculate", command=calculate_topspeed)
result_label = Label(root, text="Result will appear here")

# Layout
top_speed_label.grid(row=0, column=0)
top_speed_entry.grid(row=0, column=1, columnspan=2)

for i in range(10):
    gear_labels[i].grid(row=i+1, column=0)
    gear_entries[i].grid(row=i+1, column=1)

calculate_button.grid(row=11, column=0, columnspan=3)
result_label.grid(row=12, column=0, columnspan=3)

# Start the application
root.mainloop()
