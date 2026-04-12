#!/usr/bin/env python3

import subprocess
import requests
from io import BytesIO
from PIL import Image, ImageTk
import tkinter as tk
from tkinter import ttk  # <- IMPORT CORRETO

def get_metadata():
    try:
        title = subprocess.check_output(
            ["playerctl", "-p", "spotify", "metadata", "title"]
        ).decode().strip()

        artist = subprocess.check_output(
            ["playerctl", "-p", "spotify", "metadata", "artist"]
        ).decode().strip()

        art_url = subprocess.check_output(
            ["playerctl", "-p", "spotify", "metadata", "mpris:artUrl"]
        ).decode().strip()

        position = float(subprocess.check_output(
            ["playerctl", "-p", "spotify", "position"]
        ).decode().strip())

        duration = float(subprocess.check_output(
            ["playerctl", "-p", "spotify", "metadata", "mpris:length"]
        ).decode().strip()) / 1_000_000

        return title, artist, art_url, position, duration
    except:
        return None

def format_time(seconds):
    m = int(seconds // 60)
    s = int(seconds % 60)
    return f"{m:02}:{s:02}"

def update():
    global last_title, cover_img

    data = get_metadata()

    if data:
        title, artist, art_url, pos, dur = data

        if title != last_title:
            title_label.config(text=title)
            artist_label.config(text=artist)

            try:
                img_data = requests.get(art_url).content
                img = Image.open(BytesIO(img_data)).resize((200, 200))
                cover_img = ImageTk.PhotoImage(img)
                cover_label.config(image=cover_img)
            except:
                pass

            last_title = title

        if dur > 0:
            progress = (pos / dur) * 100
            progress_bar["value"] = progress
            time_label.config(text=f"{format_time(pos)} / {format_time(dur)}")

    else:
        title_label.config(text="Nada tocando")
        artist_label.config(text="")
        time_label.config(text="")
        progress_bar["value"] = 0

    root.after(1000, update)

# UI
root = tk.Tk()
root.title("Spotify Now Playing")
root.geometry("300x400")
root.configure(bg="#121212")

cover_label = tk.Label(root, bg="#121212")
cover_label.pack(pady=10)

title_label = tk.Label(
    root,
    text="",
    fg="white",
    bg="#121212",
    font=("Arial", 14, "bold"),
    wraplength=250
)
title_label.pack()

artist_label = tk.Label(
    root,
    text="",
    fg="gray",
    bg="#121212",
    font=("Arial", 12)
)
artist_label.pack()

progress_bar = ttk.Progressbar(root, length=250)
progress_bar.pack(pady=10)

time_label = tk.Label(
    root,
    text="",
    fg="white",
    bg="#121212",
    font=("Arial", 10)
)
time_label.pack()

last_title = ""
cover_img = None

update()
root.mainloop()
