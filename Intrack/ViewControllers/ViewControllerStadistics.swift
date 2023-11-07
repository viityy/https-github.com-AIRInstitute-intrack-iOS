//
//  ViewControllerStadistics.swift
//  Intrack
//
//  Created by Victor Martin Fuentes on 31/7/23.
//

import UIKit
import Charts


class ViewControllerStadistics: UIViewController, ChartViewDelegate, AxisValueFormatter, UIGestureRecognizerDelegate {
    
    
    //ELEMENTOS DE LA VISTA
    @IBOutlet weak var stadisticsView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var maxMinView: UIView!
    @IBOutlet weak var redLabel: UILabel!
    @IBOutlet weak var blueLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var selectedImg: UIImageView!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var flexDegrees: UILabel!
    
    
    //VARIABLES AUXILIARES
    var lineChartView: LineChartView!
    var arraySessionData: [DataSession] = []
    var vData: [DataSession] = []
    var frameX = 0.0
    var frameY = 0.0
    var minLimit: Double = 0.0
    var maxLimit: Double = 0.0
    var arrayDays: [String] = []
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectedImg.loadGif(name: "loopB")
        selectedImg.isHidden = true
        
        self.tabBarController?.navigationItem.title = "Estadisticas"
        
        
        
        //redLabel.isHidden = true
        //blueLabel.isHidden = true
        dateLabel.isHidden = true
        
        scrollView.refreshControl = refresh
        scrollView.refreshControl?.isHidden = false
        
        scrollView.refreshControl?.beginRefreshing()
        scrollToPosition(CGFloat(-200))
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.tabBarController?.navigationItem.title = "Estadisticas"
        
        scrollView.refreshControl?.beginRefreshing()
        scrollToPosition(CGFloat(-200))
        
        /*for subview in stadisticsView.subviews { // resetear las vistas
         subview.removeFromSuperview()
         }*/
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        handleRefresh(refresh)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        self.scrollView.refreshControl?.endRefreshing()
        
    }
    
    
    
    // FUNCIONES DE ELEMENTOS DE LA VISTA
    
    func viewChart(vecData: [DataSession]) {
        
        //*********************************************************************
        
        // Configurar los colores para los degradados
        let redGradientColors: [CGColor] = [
            UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 0.3).cgColor,
            UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 1.0).cgColor
        ]
        
        let blueGradientColors: [CGColor] = [
            UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 0.3).cgColor,
            UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 4.0).cgColor
        ]
        
        //*********************************************************************
        
        
        
        lineChartView = LineChartView(frame: CGRect(x: 0, y: 0,
                                                    width: stadisticsView.frame.size.width + 70 ,
                                                    height: stadisticsView.frame.size.height))
        
        print(view.frame.size.width)
        print(stadisticsView.frame.size.width)
        
        
        // Centrar el gráfico dentro de la stadisticsView
        lineChartView.center = CGPoint(x: stadisticsView.frame.size.width / 2, y: stadisticsView.frame.size.height / 2)
        
        // Crear la dos lineas del grafico
        var entries1 = [ChartDataEntry]()
        var entries2 = [ChartDataEntry]()
        
        //crear las dos lineas de los limites
        var entries3 = [ChartDataEntry]()
        var entries4 = [ChartDataEntry]()
        
        
        
        for x in 0..<vecData.count {  //mostrar los puntos de la grafica
            entries1.append( ChartDataEntry(x: Double(x), y: vecData[x].min!) )
            entries2.append( ChartDataEntry(x: Double(x), y: vecData[x].max!) )
            
        }
        
        //mostrar las lineas de los limites
        entries3.append(ChartDataEntry(x: Double(0), y: Double(minLimit)))
        entries4.append(ChartDataEntry(x: Double(0), y: Double(maxLimit)))
        entries3.append(ChartDataEntry(x: Double(vecData.count-1), y: Double(minLimit)))
        entries4.append(ChartDataEntry(x: Double(vecData.count-1), y: Double(maxLimit)))
        
        
        
        // personalizar los limites
        let lineChartDataSet3 = LineChartDataSet(entries: entries3, label: "minLimit")
        
        lineChartDataSet3.drawValuesEnabled = false
        lineChartDataSet3.mode = .cubicBezier
        lineChartDataSet3.drawCirclesEnabled = false // quitar círculos de los limites
        lineChartDataSet3.valueFont = UIFont.systemFont(ofSize: 10.0) // Personaliza la fuente de las etiquetas
        
        // Configurar el color rojo para la línea del mínimo
        lineChartDataSet3.setColor(UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 1.0))
        lineChartDataSet3.lineWidth = 2.0
        lineChartDataSet3.lineDashLengths = [5.0, 2.0]
        
        
        
        // personalizar los limites
        let lineChartDataSet4 = LineChartDataSet(entries: entries4, label: "maxLimit")
        lineChartDataSet4.drawValuesEnabled = false
        lineChartDataSet4.mode = .cubicBezier
        lineChartDataSet4.drawCirclesEnabled = false // quitar círculos de los limites
        lineChartDataSet4.valueFont = UIFont.systemFont(ofSize: 10.0) // Personaliza la fuente de las etiquetas
        
        // Configurar el color azul  para la línea del maximo
        lineChartDataSet4.setColor(UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0))
        lineChartDataSet4.lineWidth = 2.0
        lineChartDataSet4.lineDashLengths = [5.0, 2.0]
        
        
        
        // personalizar las linea del minimo del grafico
        let lineChartDataSet1 = LineChartDataSet(entries: entries1, label: "Min")
        lineChartDataSet1.drawValuesEnabled = false
        lineChartDataSet1.mode = .cubicBezier
        
        // Configurar un rojo para la linea del maximo
        lineChartDataSet1.setColor(UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 1.0))
        lineChartDataSet1.lineWidth = 2.0
        
        // Configurar el relleno debajo de la línea roja con un degradado de color
        lineChartDataSet1.fill = LinearGradientFill(gradient: createGradient(colors: redGradientColors), angle: 90.0)
        lineChartDataSet1.drawFilledEnabled = true
        lineChartDataSet1.fillFormatter = DefaultFillFormatter { dataSet, dataProvider in
            return CGFloat(self.minLimit - 50)
        }
        
        // Configurar lineChartDataSet1 (rojo)
        lineChartDataSet1.drawCirclesEnabled = true // Habilitar círculos
        lineChartDataSet1.circleRadius = 7.0 // Tamaño de los círculos
        lineChartDataSet1.circleColors = [UIColor.red] // Color de los círculos (puedes usar un arreglo para diferentes colores)
        lineChartDataSet1.circleHoleRadius = 4.0 // Tamaño del agujero en el círculo (0.0 para círculos sólidos)
        
        
        
        // personalizar las linea del máximo del grafico
        let lineChartDataSet2 = LineChartDataSet(entries: entries2, label: "Max")
        lineChartDataSet2.drawValuesEnabled = false
        lineChartDataSet2.mode = .cubicBezier
        
        // Configurar un azul para la linea del maximo
        lineChartDataSet2.setColor(UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0))
        lineChartDataSet2.lineWidth = 2.0
        
        
        
        // Configurar el relleno debajo de la línea azul con un degradado de color
        lineChartDataSet2.fill = LinearGradientFill(gradient: createGradient(colors: blueGradientColors), angle: 90.0)
        lineChartDataSet2.drawFilledEnabled = true
        lineChartDataSet2.fillFormatter = DefaultFillFormatter { dataSet, dataProvider in
            return CGFloat(self.minLimit - 50)
        }
        
        // Configurar lineChartDataSet2 (azul)
        lineChartDataSet2.drawCirclesEnabled = true // Habilitar círculos
        lineChartDataSet2.circleRadius = 7.0 // Tamaño de los círculos
        lineChartDataSet2.circleColors = [UIColor.blue] // Color de los círculos (puedes usar un arreglo para diferentes colores)
        lineChartDataSet2.circleHoleRadius = 4.0 // Tamaño del agujero en el círculo (0.0 para círculos sólidos)
        
        
        // configurar highlights del gráfico
        lineChartDataSet1.drawVerticalHighlightIndicatorEnabled = false
        lineChartDataSet1.drawHorizontalHighlightIndicatorEnabled = false
        lineChartDataSet2.drawVerticalHighlightIndicatorEnabled = false
        lineChartDataSet2.drawHorizontalHighlightIndicatorEnabled = false
        lineChartDataSet3.drawVerticalHighlightIndicatorEnabled = false
        lineChartDataSet3.drawHorizontalHighlightIndicatorEnabled = false
        lineChartDataSet4.drawVerticalHighlightIndicatorEnabled = false
        lineChartDataSet4.drawHorizontalHighlightIndicatorEnabled = false
        
        
        // Create a line chart data object
        let lineChartData = LineChartData(dataSets: [lineChartDataSet2, lineChartDataSet1, lineChartDataSet3, lineChartDataSet4])
        
        
        // Configurar las etiquetas personalizadas en el eje X utilizando el protocolo AxisValueFormatter
        lineChartView.xAxis.valueFormatter = self
        
        if( (vData.count % 2) == 0){
            lineChartView.xAxis.setLabelCount(6, force: true) // Mostrar exactamente x etiquetas
        } else {
            lineChartView.xAxis.setLabelCount(7, force: true) // Mostrar exactamente x etiquetas
        }
        
        lineChartView.xAxis.labelPosition = .top
        lineChartView.xAxis.labelFont = UIFont.systemFont(ofSize: 10.0)
        
        
        // quitar la leyenda (lo que es cada cosa)
        lineChartView.legend.enabled = false
        
        
        // Personalizar el fondo de la gráfica
        lineChartView.backgroundColor = UIColor.white
        lineChartView.gridBackgroundColor = UIColor.white
        
        
        // ocultar los datos de los ejes X e Y
        lineChartView.leftAxis.labelTextColor = UIColor.clear
        lineChartView.rightAxis.labelTextColor = UIColor.clear
        
        
        // limitando los margenes de la gráfica
        
        var maxL = maxLimit
        var minL = minLimit
        
        for session in vecData {
            
            if let maxValue = session.max {
                if(maxValue > maxL){ maxL = maxValue}
            }
            
            if let minValue = session.min {
                if(minValue > minL){ minL = minValue}
            }
        }
        
        
        if( maxL > maxLimit  ){
            lineChartView.leftAxis.axisMaximum = maxL + 10
            lineChartView.rightAxis.axisMaximum = maxL + 10
        } else {
            lineChartView.leftAxis.axisMaximum = maxLimit + 10
            lineChartView.rightAxis.axisMaximum = maxLimit + 10
        }

        if( minL < minLimit ){
            lineChartView.leftAxis.axisMinimum = minL - 50
            lineChartView.rightAxis.axisMinimum = minL - 50
        } else {
            lineChartView.leftAxis.axisMinimum = minLimit - 50
            lineChartView.rightAxis.axisMinimum = minLimit - 50
        }
        
        // Agregar una animación al cargar la gráfica
        lineChartView.animate(xAxisDuration: 1.0)
        
        
        //***************************************************************
        
        lineChartView.xAxis.drawAxisLineEnabled = false
        lineChartView.leftAxis.drawAxisLineEnabled = false
        lineChartView.rightAxis.drawAxisLineEnabled = false
        
        lineChartView.leftAxis.drawGridLinesEnabled = false
        lineChartView.rightAxis.drawGridLinesEnabled = false
        lineChartView.xAxis.drawGridLinesEnabled = true
        //***************************************************************
        
        
        // Agregamos el delegado
        lineChartView.delegate = self
        
        
        //agregamos los datos de la gráfica que hemos configurado
        lineChartView.data = lineChartData
        
        
        // configuramos los gestos en el gráfico
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tapGesture.delegate = self
        lineChartView.addGestureRecognizer(tapGesture)
        
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(handleTap2(_:))) //si tocamos fuera de la gráfica
        view.addGestureRecognizer(tapGesture2)
        
        
        lineChartView.scaleXEnabled = true // Habilitar el zoom en el eje X
        lineChartView.scaleYEnabled = true // Habilitar el zoom en el eje Y
        lineChartView.pinchZoomEnabled = true // Habilitar el zoom mediante pellizco
        
        let maxZoom = 3.0 //solo se puede hacer zoom hasta x3
        lineChartView.viewPortHandler.setMaximumScaleX(maxZoom)
        lineChartView.viewPortHandler.setMaximumScaleY(maxZoom)
        
        lineChartView.dragDecelerationEnabled = false
        
        lineChartView.backgroundColor = .clear
        
        // añadir el gráfico a la vista
        stadisticsView.addSubview(lineChartView)
        
        self.scrollView.refreshControl?.endRefreshing()
        
    }
    
    
    
    
    // FUNCIONES AUXILIARES
    
    func scrollToPosition(_ position: CGFloat) {
        let desiredContentOffset = CGPoint(x: 0, y: position)
        // Realiza la animación de scroll
        scrollView.setContentOffset(desiredContentOffset, animated: true)
    }
    
    var refresh: UIRefreshControl{
        let ref = UIRefreshControl()
        ref.addTarget(self, action: #selector(handleRefresh(_:)), for: .valueChanged)
        return ref
    }
    
    @objc func handleRefresh(_ control: UIRefreshControl){
        print("REFRESH")
        
        for subview in stadisticsView.subviews { // resetear las vistas
            subview.removeFromSuperview()
        }
        
        dateLabel.isHidden = true
        flexDegrees.text = "---"
        date.text = "---"
        selectedImg.isHidden =  true
        
        getLimitsAndSessions()
        
    }
    
    
    func chartScaled(_ chartView: ChartViewBase, scaleX: CGFloat, scaleY: CGFloat) { // cuando se hace zoom que se oculten las etiquetas
        
        if scaleX != 1.0 || scaleY != 1.0 {
            // Se está realizando un gesto de zoom
            dateLabel.isHidden = true
            flexDegrees.text = "---"
            date.text = "---"
            selectedImg.isHidden =  true
            print("Zoom en el eje X: \(scaleX), Zoom en el eje Y: \(scaleY)")
            
        }
    }
    
    
    func chartTranslated(_ chartView: ChartViewBase, dX: CGFloat, dY: CGFloat) { //cuando nos desplazamos que se oculten las etiquetas
        dateLabel.isHidden = true
        flexDegrees.text = "---"
        date.text = "---"
        selectedImg.isHidden =  true
        
    }
    
    
    
    // Implementa el método del delegado para permitir que ambos gestos funcionen simultáneamente (handletap y handletap2)
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return true
    }
    
    
    
    @objc func handleTap2(_ gesture: UITapGestureRecognizer) { // si tocamos fuera de la gráfica que se oculten las etiquetas
        
        dateLabel.isHidden = true
        flexDegrees.text = "---"
        date.text = "---"
        selectedImg.isHidden =  true
    }
    
    
    
    @objc func handleTap(_ gesture: UITapGestureRecognizer) { // para mostrar las fecha de la sesión que se pulsa
        
        // Obtener las coordenadas del punto tocado en relación con lineChartView
        let locationInView = gesture.location(in: lineChartView)
        print("////////////////")
        
        // Convertir las coordenadas a coordenadas en relación con el ViewController
        let locationInViewController = lineChartView.convert(locationInView, to: self.lineChartView)
        print("////////////////")
        
        // Obtener las coordenadas exactas de todos los puntos de las líneas
        let exactCoordinates = getCoordinatesForPoints(lineChartView: lineChartView)
        
        var exactCoordinatesView: [CGPoint] = []
        
        for (_, coordinates) in exactCoordinates {
            for coordinate in coordinates {
                // Convertir las coordenadas del punto tocado a coordenadas de la vista
                let pointInView = lineChartView.convert(CGPoint(x: coordinate.x, y: coordinate.y), to: self.view)
                
                exactCoordinatesView.append(pointInView)
                
                // pointInView ahora contiene las coordenadas convertidas a coordenadas de la vista
                print("Coordenada en la vista: x = \(pointInView.x), y = \(pointInView.y)")
                
            }
        }
        
        var cont = 0
        
        // Verificar si el punto tocado coincide con alguna coordenada de las líneas
        for (_, coordinates) in exactCoordinates {
            for coordinate in coordinates {
                
                let touchRect = CGRect(x: coordinate.x - 10, y: coordinate.y - 10, width: 20, height: 20)
                if touchRect.contains(locationInView) {
                    // Si el punto tocado está cerca de alguna coordenada, mostrar la etiqueta dateLabel
                    
                    //dateLabel.isHidden = false
                    
                    // Escala inicial de la etiqueta
                    dateLabel.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                    
                    // Luego, cuando desees mostrar la etiqueta con una animación de expansión:
                    UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseOut], animations: {
                        // Restaura la escala original (1.0) para expandir la etiqueta
                        self.dateLabel.transform = .identity
                        self.selectedImg.transform = .identity
                    }) { (finished) in
                        // La animación ha terminado, asegúrate de que la etiqueta esté visible
                        self.dateLabel.isHidden = false
                        //self.redLabel.isHidden = false
                        //self.blueLabel.isHidden = false
                        self.selectedImg.isHidden = false
                        
                    }
                    
                    
                    //ajsutar el tamaño de la etiqueta
                    var labelWidth: CGFloat = 160.0
                    var labelHeight: CGFloat = 60.0
                    
                    if( locationInViewController.x > stadisticsView.frame.width/2 ){
                        
                        labelWidth = -160.0
                        
                        print("derecha")
                        
                        if(locationInViewController.y < stadisticsView.frame.height/2){
                            
                            labelHeight = 60.0
                            
                            print(locationInViewController.y)
                            print(stadisticsView.frame.height/2)
                            print("arriba")
                            
                        }else{
                            labelHeight = -60.0
                            print(locationInViewController.y)
                            print(stadisticsView.frame.height/2)
                            
                            print("abajo")
                            
                        }
                    }
                    
                    if( locationInViewController.x < stadisticsView.frame.width/2 ){
                        
                        labelWidth = 160.0
                        
                        print("izquierda")
                        
                        
                        if(locationInViewController.y < stadisticsView.frame.height/2){
                            labelHeight = 60.0
                            
                            print(locationInViewController.y)
                            print(stadisticsView.frame.height/2)
                            print("arriba")
                            
                        }else{
                            labelHeight = -60.0
                            print(locationInViewController.y)
                            print(stadisticsView.frame.height/2)
                            print("abajo")
                            
                        }
                    }
                    
                    
                    print("**************")
                    
                    // Ajustar la posición para que la esquina superior izquierda esté en el punto tocado
                    let labelX = exactCoordinatesView[cont].x
                    let labelY = exactCoordinatesView[cont].y
                    dateLabel.frame = CGRect(x: labelX, y: labelY, width: labelWidth, height: labelHeight)
                    
                    selectedImg.frame = CGRect(x: labelX-100, y: labelY-100, width: 200, height: 200)
                    
                    
                    return
                }
                cont = cont + 1
            }
        }
        
        // Si el punto tocado no coincide con ninguna coordenada, ocultar la etiqueta dateLabel
        dateLabel.isHidden = true
        flexDegrees.text = "---"
        date.text = "---"
        selectedImg.isHidden = true
        
    }
    
    
    
    
    func getCoordinatesForPoints(lineChartView: LineChartView) -> [Int: [CGPoint]] {
        
        var exactCoordinates: [Int: [CGPoint]] = [:]
        
        // Obtener los datos de los conjuntos de puntos de las líneas
        guard let dataSets = lineChartView.data?.dataSets as? [LineChartDataSet] else { return exactCoordinates }
        
        // Iterar sobre los conjuntos de datos para obtener las coordenadas de los puntos
        for dataSetIndex in 0..<dataSets.count-2 { //-2 para excluir las lineas que marcan los limites
            var coordinates: [CGPoint] = []
            // Obtener los puntos (entradas) del conjunto de datos
            let entries = dataSets[dataSetIndex].entries
            // Iterar sobre los puntos para obtener las coordenadas
            for entry in entries {
                // Calcular las coordenadas del punto (x, y) en la vista del gráfico
                let x = CGFloat(entry.x)
                let y = CGFloat(entry.y)
                let point = lineChartView.getTransformer(forAxis: dataSets[dataSetIndex].axisDependency).pixelForValues(x: x, y: y)
                coordinates.append(point)
            }
            exactCoordinates[dataSetIndex] = coordinates
        }
        
        return exactCoordinates
    }
    
    
    
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        // añadimos los valores de la sesión que se ha seleccionado para luego mostrarlos
        
        let index = Int(entry.x)
        if index >= 0 && index < vData.count {
            
            let dataSetIndex = highlight.dataSetIndex
            
            if dataSetIndex == 0 {
                // La entrada seleccionada pertenece a lineChartDataSet2 (primer conjunto de datos)
                // Realiza acciones específicas para lineChartDataSet2
                print("Punto seleccionado en lineChartDataSet2 (gráfica azul)")
                selectedImg.loadGif(name: "loopB")
                
                if let maxValue = vData[index].max {
                    dateLabel.text = String(format: "%.1fº", maxValue)
                    
                } else {
                    redLabel.text = "---" // o cualquier otro valor predeterminado si min es nil
                }
                
                
            } else if dataSetIndex == 1 {
                // La entrada seleccionada pertenece a lineChartDataSet1 (segundo conjunto de datos)
                // Realiza acciones específicas para lineChartDataSet1
                print("Punto seleccionado en lineChartDataSet1 (gráfica roja)")
                selectedImg.loadGif(name: "loopR")
                
                if let minValue = vData[index].min {
                    dateLabel.text = String(format: "%.1fº", minValue)
                    
                } else {
                    redLabel.text = "---" // o cualquier otro valor predeterminado si min es nil
                }
                
                
            }
            
            
            let selectedDate = convertTimestampToDate(vData[index].timestamp_end)
            date.text = selectedDate
            dateLabel.isHidden = false
            
            if let minValue = vData[index].min, let maxValue = vData[index].max {
                flexDegrees.text = String(format: "%.1fº", (maxValue - minValue))
                
            } else {
                redLabel.text = "---" // o cualquier otro valor predeterminado si min es nil
            }
            
            
        }
    }
    
    
    func chartValueNothingSelected(_ chartView: ChartViewBase) { //cuando no hay nada seleccionado que las etiquetas se oculten
        
        dateLabel.isHidden = true
        //blueLabel.isHidden = true
        //redLabel.isHidden = true
        selectedImg.isHidden =  true
        
        flexDegrees.text = "---"
        date.text = "---"
        
        
    }
    
    
    func createGradient(colors: [CGColor]) -> CGGradient { //funcion para crear los degradados de colores
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colorLocations: [CGFloat] = Array(0..<colors.count).map { CGFloat($0) / CGFloat(colors.count - 1) }
        return CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: colorLocations)!
    }
    
    
    func getSessions() {
        
        
        WebRequest.getSessions { sessions in
            
            self.vData = []
            
            print("OK getSessions")
            
            self.arraySessionData = sessions
            self.addSessions()
            
            
        } error: { errorMessage in
            
            self.scrollView.refreshControl?.endRefreshing()
            print("NO OK getSessions")
            
        }
        
    }
    
    
    
    func addSessions (){
        // Iterar sobre arraySessionData y construir vData
        
        var first = true // para duplicar primero y ultimo (estetica)
        
        for session in arraySessionData.reversed() {
            // Aquí puedes acceder a las propiedades de cada instancia de sessionData
            let min = session.min
            let max = session.max
            
            if(min == nil || max == nil ){
                //print("Esta sesion no se puede mostrar en la grafica")
            }else{
                
                if( first ) {
                    vData.append( DataSession(id: session.id, timestamp_init: session.timestamp_init, timestamp_end: session.timestamp_end, max: session.max, min: session.min, id_user: session.id_user, id_quest: session.id_quest) )
                    first = false
                }
                
                vData.append( DataSession(id: session.id, timestamp_init: session.timestamp_init, timestamp_end: session.timestamp_end, max: session.max, min: session.min, id_user: session.id_user, id_quest: session.id_quest) )
            }
        }
        
        vData.append(vData[vData.count-1])
        
        //print(vData)
        viewChart(vecData: vData) // añadimos los datos al gráfico
        
    }
    

    
    func convertTimestampToDate(_ timestamp: Int) -> String { //funcion para convertir el timestamp a fecha
        
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        
        let index = Int(value)
        if index >= 0 && index < vData.count {
            if index == 0 || index == vData.count - 1 {
                // No mostrar etiquetas para el primer y último valor
                return ""
            }
            return convertTimestampToDate(vData[index].timestamp_end)
        } else {
            return ""
        }
    }
    
    
    func getLimitsAndSessions(){
        
        WebRequest.getLimits { limits in
            print("OK getLimits")
            // Asigna los valores a las variables
            self.minLimit = limits.min_limit
            self.maxLimit = limits.max_limit
            
            self.redLabel.text = String(format: "%.1fº", limits.min_limit)
            self.blueLabel.text = String(format: "%.1fº", limits.max_limit)
            
            self.getSessions()
            
            print(self.maxLimit)
            print(self.minLimit)
            
        } error: { errorMessage in
            self.scrollView.refreshControl?.endRefreshing()
            print("NO OK getSessions")
            
        }
        
    }
    
}




