function fzf_select_kube_context
  set fzf_flags --reverse

  kubectl config get-contexts --no-headers -o name|fzf $fzf_flags|read foo

  if [ $foo ]
    kubectl config use-context $foo
  end
end
