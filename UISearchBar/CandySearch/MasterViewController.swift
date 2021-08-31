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
    searchController.obscuresBackgroundDuringPresentation = false //UISearchController oculta el controlador de vista que contiene la información que está buscando. Esto es útil si está utilizando otro controlador de vista para su searchResultsController. En este caso, configuró la vista actual para mostrar los resultados, por lo que no desea ocultar su vista.
    searchController.searchBar.placeholder = "Search Candies" //Placeholder del componente UISearchBar
    navigationItem.searchController = searchController// agrega la barra de búsqueda al elemento de navegación.
    definesPresentationContext = true //se asegura de que la barra de búsqueda no permanezca en la pantalla si el usuario navega a otro controlador de vista mientras el UISearchController está activo.
    
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
    
    //corrige el error para mostar el detalle correcto, según el dulce buscado
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
      return candy.name.lowercased().contains(searchText.lowercased())//Retorna Verdadero o falso para agregar el dulce al arreglo de resultados, se convierten las cadenas de texto en minusculas.
    }
    
    tableView.reloadData()//recarga la tabla
  }


  //Ahora, cada vez que el usuario agrega o elimina texto en la barra de búsqueda, UISearchController informará a la clase MasterViewController del cambio a través de una llamada a for searchController, que a su vez llama a filterContentForSearchText
  func updateSearchResults(for searchController: UISearchController) {
    let searchBar = searchController.searchBar
    filterContentForSearchText(searchBar.text!)
  }
  
  
  //Evalua si esta el usuario esta buscando algo.
  var isFiltering: Bool {
    return searchController.isActive && !isSearchBarEmpty
  }

}

extension MasterViewController: UITableViewDataSource {
  
  //Se verifica si el usuario esta realizando una busqueda.
  func tableView(_ tableView: UITableView,
                 numberOfRowsInSection section: Int) -> Int {
    if isFiltering {
      return filteredCandies.count
    }
      
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

let searchController = UISearchController(searchResultsController: nil)//método para cumplir con el protocolo UISearchResultsUpdating

