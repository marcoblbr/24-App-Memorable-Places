//
//  ViewController.swift
//  07 - Table Views
//
//  Created by Marco Linhares on 6/13/15.
//  Copyright (c) 2015 Marco Linhares. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var list = Model.singleton
    
    @IBOutlet weak var table: UITableView!
    
    @IBAction func buttonErase(sender: AnyObject) {
        // mostra um alerta em popup com 2 opções
        var refreshAlert = UIAlertController(title: "Erase all?", message: "All items will be erased.", preferredStyle: UIAlertControllerStyle.Alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action: UIAlertAction!) in
            // doesn't do anything
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Erase", style: .Default, handler: { (action: UIAlertAction!) in
            
            // remove all rows
            self.list.removeAll()
            
            self.table.reloadData()
        }))
        
        presentViewController(refreshAlert, animated: true, completion: nil)
    }
    
    // serve para informar o número de linhas da tabela
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.countElements()
    }

    // função que atualiza as células com o texto adequado e usa o dequeue corretamente
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! UITableViewCell
        
        cell.textLabel?.text = list.elementAtIndex(indexPath.row)

        return cell
    }
    
    // ocorre quando é clicado em uma célula
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("segueGoMapViewController", sender: indexPath)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueGoMapViewController" {
            
            // existe o as? ao invés do as! pois é feito um teste se o tipo pode ser convertido.
            // caso ele não seja no tipo nsindexpath, será retornado nil e isso significa que ele
            // não clicou em nenhuma célula
            let indexPath = sender as? NSIndexPath
            
            if indexPath != nil {
                let destinationController = segue.destinationViewController as! MapViewController
                
                destinationController.cameFromSegue = true
                destinationController.indexFromSegue = indexPath!.row
            }
        }
    }
    
    // função para voltar do map view controller
    @IBAction func unwindMapViewController (segue: UIStoryboardSegue) {
        if let destination = segue.sourceViewController as? MapViewController {
            self.list = destination.list

            // recarrega a tabela. a função unwind só é chamada depois que a tabela é carregada, por isso os dados
            // aparecem vazios. mas com o reloaddata, eles são atualizados e mostrados na tabela. para fazer isso
            // é preciso criar um outlet para a tableview
            table.reloadData()
        }
    }

    // para dizer o número de seções. sem essa função, não é possível remover linhas
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    // informa que as células podem ser editadas e no caso, removidas
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    // função para remover as células com um swipe lateral
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Update Items
            list.removeElement(indexPath.row)
            
            // Update Table View
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Right)
        }
    }

    // muda o texto padrão do botão de "delete" para algum outro
    func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String! {
        return "Erase"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

