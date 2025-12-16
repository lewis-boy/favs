//
//  ProfilePic.swift
//  CameraTesting
//
//  Created by csuftitan on 12/15/25.
//
import SwiftUI

struct FavoriteIcon: View{
    let color: Color
    let systemName: String
    
    var body: some View{
        ZStack{
            RoundedRectangle(cornerRadius: 12)
                .fill(color)
                .frame(width: 44, height: 44)
            Image(systemName: systemName)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.black)
        }
    }
}

