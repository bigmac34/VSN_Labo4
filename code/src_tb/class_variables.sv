class Etudiant;
	string nom;
	real   moyenne;
endclass

program Test;
  initial begin
	Etudiant e = new;
    e.nom      = "Albert";
    e.moyenne  = 5.0;
    $display("Etudiant %s. Moyenne: %e",e.nom,e.moyenne);
  end
endprogram
