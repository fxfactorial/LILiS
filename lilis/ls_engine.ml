open Ls_type

(** Get the rule that match the given symbol. *)
(* FIXME : Use something else than a list. *)
let rec get_rule ordre rules = match rules with
    [] -> None (* No rule match the symbol *)
  | t::q when t.left_mem = ordre -> Some t (* Found the rule matching the symbol *)
  | _::q -> get_rule ordre q

(** Evaluate a stream of arit_expr. *)
let eval_stream (env : Mini_calc.arit_env) l_stream =
  let f_eval_stream (ordre,ordre_args) = 
    ordre, List.map (fun f -> f env) ordre_args
  in BatEnum.map f_eval_stream l_stream

(** Apply a rule to some given arguments. *)
let exec_rule rule args =
  let env = List.fold_left2 (fun env k x -> Env.add k x env) Env.empty rule.var args in
eval_stream env (BatList.enum rule.right_mem)

(** Get the transformation function from a Lsystem. *)
let get_transformation lsys =
  let transf ordre arg = match get_rule ordre lsys.rules with
      None -> BatEnum.singleton (ordre,arg)
    | Some r -> exec_rule r arg
  in transf

(** Generate a recursive curve at the n-th generation, with the given axiom and the given transformation function. *)
let courbe_recursive m germe transformation =
  let developement lstream =
    BatEnum.concat (BatEnum.map (function (ordre,args) -> transformation ordre args) lstream)
  in
  let rec generation n l = match n with
      0 -> l
    | n -> generation (n-1) (developement l)
  in
  generation m germe

(** Generate the n-th generation of the given Lsystem. *)
let eval_lsys n lsys = courbe_recursive n (BatList.enum lsys.axiom) (get_transformation lsys)
