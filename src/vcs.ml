open Core.Std

let copy path = 
	print_string path;
	print_string "\n"



let main () = 
	let dir_list = Sys.ls_dir (Sys.getcwd ()) in 
	List.iter ~f:copy dir_list 
	



let () = 
	main ()