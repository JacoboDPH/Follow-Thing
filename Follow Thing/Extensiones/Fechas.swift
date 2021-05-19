//
//  fechas.swift
//  Follow Thing
//
//  Created by Jacobo Diego Pita Hernandez on 24/06/2020.
//  Copyright © 2020 Jacobo Diego Pita Hernandez. All rights reserved.
//

import Foundation
import UIKit

public class Fechas {
    
    public static func calculaDiasEntreDosFechas(start: Date, end: Date) -> Int {
        
        let currentCalendar = Calendar.current
        guard let start = currentCalendar.ordinality(of: .day, in: .era, for: start) else {
            return 0
        }
        guard let end = currentCalendar.ordinality(of: .day, in: .era, for: end) else {
            return 0
        }
        return end - start
    }
    
    public static func creaStringDias (numeroDia: Int,numeroDiaInvertido:Int, forzarDia:Bool) -> String {
        var desdeHace:Bool = false
        if !forzarDia {
            desdeHace = UserDefaults.standard.bool(forKey: "tapDia")
        }
        var mensaje:String = ""
        
        if !desdeHace {
            
            mensaje = "Día \(numeroDia)"
            
        }
        else {
            if numeroDiaInvertido == 0 {
                mensaje = "Hoy"
            }
            if numeroDiaInvertido == 1 {
                mensaje = "Ayer"
            }
            if numeroDiaInvertido > 1 {
                mensaje = "Hace\n\(numeroDiaInvertido) días"
            }
        }
        return mensaje
    }
    public static func fechaCompleta(dia:Int)->String {
        
        var fechaString:String = ""
        
        if dia == 0 {
            fechaString = "Hoy"
        }
        if dia > 0 || dia < 30 {
            
            fechaString = "\(dia) días"
            
        }
        return fechaString
    }
    public static var dateFormatter: DateFormatter {
    
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
        
        //        Para utilizarla datterformatter.String(from:[la fecha a formaterar])
    }
    public static var formatoFechaUltimoUso: DateFormatter {
        
        let formato = DateFormatter()
        formato.dateStyle = .short
        formato.timeStyle = .none
        
        return formato
    }
    public static func fechaCompleta(dias:Int)->String {
        
        var resultado:String = ""
         
        if dias >= 30 {
            
            let mes = (dias/30) - dias
            let messss = mes/30
            resultado = "\(messss) meses"
            let diferenciaDias = mes - dias
            if diferenciaDias <= 30 {
                let semana = (diferenciaDias/7) - diferenciaDias
                resultado = "\(messss) meses, \(semana) semanas"
            }
            
            return resultado
        }
        if dias >= 7 {
            
            let seman = (dias / 7 ) - dias
            
          resultado = "\(seman) semanas "
            return resultado
        }
        if dias < 7 {
            
            resultado = "\(dias) días"
            
            if dias == 0 {
                resultado = "Hoy"
            }
            if dias == 1 {
                resultado = "1 día"
            }
        }
        
        return resultado
    }
    static func fechaCompletaDesde(date: Date) -> String {

        let dayHourMinuteSecond: Set<Calendar.Component> = [.month, .weekOfMonth, .day, .second]
        let difference = NSCalendar.current.dateComponents(dayHourMinuteSecond, from: date, to: Date())

        let minutes = "\(difference.day ?? 0) días" + " "
        let hours = "\(difference.weekOfMonth ?? 0) semanas" + " " + minutes
        let days = "\(difference.month ?? 0) meses" + " " + hours

        if let day = difference.month, day > 0 { return days }
        if let hour = difference.weekOfMonth, hour > 0 { return hours }
        if let minute = difference.day, minute > 0 { return minutes }
       
        if "" == "" {
            return "hoy"
        }
        return ""
    }

    static func convierteFechaString(fecha:Date)-> String {
        
        
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd hh:mm:ss"
        let now = df.string(from: Date())
        return now
    }
    


}
