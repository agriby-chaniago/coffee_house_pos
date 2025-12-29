# Coffio

Coffee House POS & Self Order System

[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-blue.svg)](https://dart.dev)
[![License](https://img.shields.io/badge/License-Educational-lightgrey.svg)](#)
[![Repo Status](https://img.shields.io/badge/Status-Active-success.svg)](#)

Coffio adalah aplikasi **Point of Sale (POS) dan Self Order** untuk coffee shop yang dibangun menggunakan **Flutter**.
Aplikasi ini dirancang dengan pendekatan arsitektur modern, pemisahan fitur yang jelas, serta fokus pada kualitas kode dan skalabilitas.

Coffio memiliki dua sisi utama:

- **Admin (POS System)** — untuk operasional toko
- **Customer (Self Order System)** — untuk pemesanan mandiri oleh pelanggan

---

## Fitur Utama

### Admin — POS System

#### Manajemen Menu

- CRUD Produk
- CRUD Topping (add-ins / tambahan menu)
- Upload dan manajemen gambar produk

#### POS & Transaksi

- Keranjang pesanan (produk dan topping)
- Checkout transaksi
- Generate struk dalam format PDF
- Informasi toko terintegrasi otomatis ke struk

#### Orders Management

Manajemen seluruh pesanan masuk dengan status:

- Pending
- Preparing
- Ready
- Completed

#### Settings Admin

- Ganti password
- Ubah nama toko
- Ubah alamat toko
- Ubah nomor HP toko
  (Terintegrasi ke struk dan sisi Customer)
- Informasi versi aplikasi
- Toggle tema:
  - Dark: Catppuccin Mocha
  - Light: Catppuccin Latte

#### System Indicator

- Indikator status koneksi internet (online / offline)

---

### Customer — Self Order System

#### Self Order

- Melihat daftar produk
- Memilih topping
- Melakukan pemesanan mandiri

#### My Orders

- Riwayat seluruh pesanan Customer
- Informasi status pesanan

#### Profile

- Ganti foto profil
- Ubah nama lengkap
  (Otomatis terintegrasi ke proses pemesanan)
- Ubah nomor telepon
- Informasi email (read-only)
- Ganti password

#### Statistik Customer

- Total orders
- Total spent
- Pesanan pending
- Pesanan completed

#### Profile Settings & About

- Toggle tema Light / Dark
- Notifikasi
- About App
- Terms & Conditions
- Privacy Policy

---

## Arsitektur & Pendekatan Teknis

Coffio menggunakan **feature-based architecture** dengan pemisahan layer:

- Data
- Domain
- Presentation

Pendekatan ini bertujuan menjaga kode tetap modular, mudah dirawat, dan siap dikembangkan lebih lanjut.

---

## Tech Stack

- Flutter
- Riverpod (State Management)
- GoRouter (Declarative Routing)
- Appwrite (Authentication & Database)
- Hive (Local Storage & Offline Cache)
- GetIt (Dependency Injection)
- Freezed (Immutable Models)
- JSON Serializable (Code Generation)
- fl_chart (Data Visualization)
- pdf & printing (Receipt Generation)

---

## Offline Handling

- Penyimpanan lokal menggunakan Hive
- Monitoring koneksi menggunakan connectivity_plus
- Aplikasi menyesuaikan perilaku saat offline atau online

Pendekatan ini penting untuk sistem POS yang digunakan di kondisi lapangan.

---

## Repository Notes

- Repository ini berisi full source code
- Struktur project siap ditinjau secara teknis
- Fokus pada arsitektur, state management, dan kualitas kode

---

## Tujuan Project

Coffio dikembangkan sebagai project pembelajaran dan implementasi nyata untuk:

- Flutter application architecture
- POS & Self Order system
- Clean code dan scalable structure
- Business flow yang realistis

---

## License

Project ini dikembangkan untuk keperluan edukasi dan evaluasi teknis.

---

# Coffio

Coffee House POS & Self Order System

[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-blue.svg)](https://dart.dev)
[![License](https://img.shields.io/badge/License-Educational-lightgrey.svg)](#)
[![Repo Status](https://img.shields.io/badge/Status-Active-success.svg)](#)

Coffio is a **Point of Sale (POS) and Self Order** application for coffee shops built with **Flutter**.  
The application is designed with a modern architecture, clear feature separation, and a strong focus on code quality and scalability.

Coffio consists of two main sides:

- **Admin (POS System)** — for store operations
- **Customer (Self Order System)** — for customer self-ordering

---

## Key Features

### Admin — POS System

#### Menu Management

- Product CRUD
- Topping CRUD (add-ins)
- Product image management

#### POS & Transactions

- Cart management (products and toppings)
- Checkout process
- Receipt generation in PDF format
- Store information automatically integrated into receipts

#### Orders Management

Manage all incoming orders with statuses:

- Pending
- Preparing
- Ready
- Completed

#### Admin Settings

- Change password
- Update store name
- Update store address
- Update store phone number
  (Integrated into receipts and Customer side)
- App version information
- Theme toggle:
  - Dark: Catppuccin Mocha
  - Light: Catppuccin Latte

#### System Indicator

- Internet connectivity status indicator

---

### Customer — Self Order System

#### Self Order

- Browse product list
- Select toppings
- Place orders independently

#### My Orders

- Order history
- Order status tracking

#### Profile

- Update profile picture
- Update full name
  (Automatically used during order placement)
- Update phone number
- Email information (read-only)
- Change password

#### Customer Statistics

- Total orders
- Total spent
- Pending orders
- Completed orders

#### Profile Settings & About

- Light / Dark theme toggle
- Notifications
- About App
- Terms & Conditions
- Privacy Policy

---

## Architecture & Technical Approach

Coffio implements a **feature-based architecture** with clear separation into:

- Data layer
- Domain layer
- Presentation layer

This approach improves maintainability, scalability, and code readability.

---

## Tech Stack

- Flutter
- Riverpod (State Management)
- GoRouter (Declarative Routing)
- Appwrite (Authentication & Database)
- Hive (Local Storage & Offline Cache)
- GetIt (Dependency Injection)
- Freezed (Immutable Models)
- JSON Serializable (Code Generation)
- fl_chart (Data Visualization)
- pdf & printing (Receipt Generation)

---

## Offline Support

- Local data caching using Hive
- Connectivity monitoring using connectivity_plus
- Adaptive behavior for offline and online scenarios

This is essential for real-world POS systems.

---

## Repository Notes

- This repository contains full source code
- Structured and ready for technical review
- Focused on architecture, state management, and implementation quality

---

## Project Purpose

Coffio is developed as an educational and practical project focusing on:

- Flutter application architecture
- POS & Self Order systems
- Clean code and scalable design
- Realistic business workflows

---

## License

This project is intended for educational and technical evaluation purposes.
