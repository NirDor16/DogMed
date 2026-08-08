# DogMed

An iOS app for dog owners to keep track of their dogs' medications.

## About

DogMed helps you manage multiple dogs and stay on top of their medication schedules. All medication details are entered by you based on your vet's instructions — the app just helps you organize and remember them, it doesn't recommend anything.

## Features

- **Today** — see every medication due today across all your dogs, and mark it as given
- **My Dogs** — add, edit, and remove dogs, each with a photo, breed, age, and notes
- **Medications** — add, edit, and remove medications per dog with dosage, schedule (once a day, twice a day, or specific days), start/end dates, notes, and vet name
- **History** — tracks whether each dose was given on past dates, not just today
- **Synced with Firebase** — your data is saved to Firebase Realtime Database and updates live
- **Dark mode** — Light, Dark, or System, chosen in Settings
- **Portrait and landscape** support throughout

## Tech

- Swift / UIKit, built with Storyboards
- Firebase Realtime Database + Anonymous Authentication
- No third-party dependencies beyond the Firebase SDK (via Swift Package Manager)

## Requirements

- iOS 16+
- Xcode 15+
- A Firebase project with Realtime Database and Anonymous Auth enabled (see setup notes)
