/// Copyright (c) 2019 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit

class MasterViewController: UIViewController, UISearchResultsUpdating {

  

  @IBOutlet var tableView: UITableView!
  @IBOutlet var searchFooter: SearchFooter!
  @IBOutlet var searchFooterBottomConstraint: NSLayoutConstraint!
  
  var candies: [Candy] = []
  let searchController = UISearchController(searchResultsController: nil) //Se especifica al controlador que va a utilizar la misma vista para mostrar los resultados.
  var filteredCandies: [Candy] = [] //contendra los caramelos que busca el usuario.

  
  override func viewDidLoad() {
    super.viewDidLoad()
    candies =  Candy.candies() //Se inicializa la tabla maestra con objetos.

    searchController.searchResultsUpdater = self //Informa a la clase de cualquier cambio el componente UISearchBar
    searchController.obscuresBackgroundDuringPresentation = false //UISearchController oculta el controlador de vista que contiene la informaci??n que est?? buscando. Esto es ??til si est?? utilizando otro controlador de vista para su searchResultsController. En este caso, configur?? la vista actual para mostrar los resultados, por lo que no desea ocultar su vista.
    searchController.searchBar.placeholder = "Search Candies" //Placeholder del componente UISearchBar
    navigationItem.searchController = searchController// agrega la barra de b??squeda al elemento de navegaci??n.
    definesPresentationContext = true //se asegura de que la barra de b??squeda no permanezca en la pantalla si el usuario navega a otro controlador de vista mientras el UISearchController est?? activo.
    
    searchController.searchBar.scopeButtonTitles = Candy.Category.allCases
      .map { $0.rawValue }
    searchController.searchBar.delegate = self
    
    
    
    //Observador para controlar el indicador de resultados de busquedas, se ajustara dependiendo de la posicion del teaclado.
    let notificationCenter = NotificationCenter.default
    notificationCenter.addObserver(
      forName: UIResponder.keyboardWillChangeFrameNotification,
      object: nil, queue: .main) { (notification) in
        self.handleKeyboard(notification: notification)
    }
    notificationCenter.addObserver(
      forName: UIResponder.keyboardWillHideNotification,
      object: nil, queue: .main) { (notification) in
        self.handleKeyboard(notification: notification)
    }


    
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    if let indexPath = tableView.indexPathForSelectedRow {
      tableView.deselectRow(at: indexPath, animated: true)
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard
      segue.identifier == "ShowDetailSegue",
      let indexPath = tableView.indexPathForSelectedRow,
      let detailViewController = segue.destination as? DetailViewController
      else {
        return
    }
    
    //corrige el error para mostar el detalle correcto, seg??n el dulce buscado
    let candy: Candy
    if isFiltering {
      candy = filteredCandies[indexPath.row]
    } else {
      candy = candies[indexPath.row]
    }

    detailViewController.candy = candy
  }
  
  //retorna verdadero si el texto escrito en la barra esta vacio.
  var isSearchBarEmpty: Bool {
    return searchController.searchBar.text?.isEmpty ?? true
  }
  
  
  //filtra los caramelos en base al texto escrito por el usuario.
  func filterContentForSearchText(_ searchText: String,
                                  category: Candy.Category? = nil) {
    filteredCandies = candies.filter { (candy: Candy) -> Bool in
      let doesCategoryMatch = category == .all || candy.category == category
      //return candy.name.lowercased().contains(searchText.lowercased())//Retorna Verdadero o falso para agregar el dulce al arreglo de resultados, se convierten las cadenas de texto en minusculas.
      if isSearchBarEmpty {
        return doesCategoryMatch
      } else {
        return doesCategoryMatch && candy.name.lowercased()
          .contains(searchText.lowercased())
      }
    }
    
    tableView.reloadData()//recarga la tabla
  }


  //Ahora, cada vez que el usuario agrega o elimina texto en la barra de b??squeda, UISearchController informar?? a la clase MasterViewController del cambio a trav??s de una llamada a for searchController, que a su vez llama a filterContentForSearchText
  func updateSearchResults(for searchController: UISearchController) {
    let searchBar = searchController.searchBar
    let category = Candy.Category(rawValue:
      searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex])
    filterContentForSearchText(searchBar.text!, category: category)
  }

  
  
  //Evalua si esta el usuario esta buscando algo.
  var isFiltering: Bool {
    let searchBarScopeIsFiltering = //verifica si la categor??a del caramelo coincide con la categor??a que pasa en el UIsearchBar
      searchController.searchBar.selectedScopeButtonIndex != 0
    return searchController.isActive &&
      (!isSearchBarEmpty || searchBarScopeIsFiltering)
  }
  
  
  func handleKeyboard(notification: Notification) {
    //Verifica si la notificaci??n se debe mostrar por encima del teclado
    guard notification.name == UIResponder.keyboardWillChangeFrameNotification else {
      searchFooterBottomConstraint.constant = 0
      view.layoutIfNeeded()
      return
    }

    guard
      let info = notification.userInfo,
      let keyboardFrame = info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
      else {
        return
    }

    //Si la notificaci??n identifica el rect??ngulo del marco final del teclado, mueva el pie de p??gina de b??squeda justo encima del teclado.
    let keyboardHeight = keyboardFrame.cgRectValue.size.height
    UIView.animate(withDuration: 0.1, animations: { () -> Void in
      self.searchFooterBottomConstraint.constant = keyboardHeight
      self.view.layoutIfNeeded()
    })
  }


}

extension MasterViewController: UITableViewDataSource {
  
  //Se verifica si el usuario esta realizando una busqueda.
  func tableView(_ tableView: UITableView,
                 numberOfRowsInSection section: Int) -> Int {
    if isFiltering {
      //Actualiza la cantidad de resultados
      searchFooter.setIsFilteringToShow(filteredItemCount:
            filteredCandies.count, of: candies.count)
      return filteredCandies.count
    }
    //Actualiza la cantidad de resultados
    searchFooter.setNotFiltering()
    return candies.count
  }

  
  func tableView(_ tableView: UITableView,
                 cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    let candy: Candy
    if isFiltering { //determinan que arreglo mostrar.
      candy = filteredCandies[indexPath.row] //datos retornados en la busqueda o criterio qu eingreso el usuario.
    } else {
      candy = candies[indexPath.row]
    }
    cell.textLabel?.text = candy.name
    cell.detailTextLabel?.text = candy.category.rawValue
    return cell
  }

}


//Se agrega una extensi??n para realizar la busqueda por la categoria.
extension MasterViewController: UISearchBarDelegate {
  func searchBar(_ searchBar: UISearchBar,
      selectedScopeButtonIndexDidChange selectedScope: Int) {
    let category = Candy.Category(rawValue:
      searchBar.scopeButtonTitles![selectedScope])
    filterContentForSearchText(searchBar.text!, category: category)
  }
}



