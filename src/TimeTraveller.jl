module TimeTraveler

export @when_freshly_loaded, @back_in_the_day

const LOADED_AGES = Dict{Base.PkgId, UInt64}()

function __init__()
    push!(Base.package_callbacks, _store_load_age)
end

function _store_load_age(pkgid::Base.PkgId)
    LOADED_AGES[pkgid] = Base.get_world_counter()
end

loaded_age(package::Module) = LOADED_AGES[Base.PkgId(package)]


"""
    @when_freshly_loaded(package, code)

Runs the `code` in the world-age that was when the package had just been loaded.
Before any overloads were added or monkey patching done, or Revise based editting etc.
This returns the value returned by the final expression in code.
"""
macro when_freshly_loaded(package, code)
    quote
        target_age = loaded_age($(esc(package)))
        @back_in_the_day(target_age, $(esc(code)))
    end
end


"""
    @back_in_the_day(age, code)

Runs the `code` in the world-age given by `age`.
This is a concvienence wrapper for `Base.invoke_in_world`.
"""
macro back_in_the_day(age, code)
    _rewrite_all_calls(age, code)
end

_rewrite_all_calls(_, literal) = esc(literal)
function _rewrite_all_calls(age, code::Expr)
    new_args = map(code.args) do arg
        _rewrite_all_calls(age, arg)
    end
    if code.head == :call
        return Expr(:call, Base.invoke_in_world, age, new_args...)
    else
        return Expr(code.head, new_args...)
    end
end

end  # module