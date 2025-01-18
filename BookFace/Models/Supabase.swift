//
//  Supabase.swift
//  BookFace
//
//  Created by Tristan Chay on 19/1/25.
//

import SwiftUI
import Supabase

let supabase = SupabaseClient(
    supabaseURL: URL(string: "https://ippvcuesbyugichlyonv.supabase.co")!,
    supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlwcHZjdWVzYnl1Z2ljaGx5b252Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzcyMDk1ODcsImV4cCI6MjA1Mjc4NTU4N30.wu7Vd2E4bImFBUzde5Y7Oy3dyiO7hlIehvpKNaJjdP8"
)
