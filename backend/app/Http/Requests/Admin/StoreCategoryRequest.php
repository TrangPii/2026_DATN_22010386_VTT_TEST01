<?php

namespace App\Http\Requests\Admin;

use Illuminate\Foundation\Http\FormRequest;

class StoreCategoryRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()?->role === 'ADMIN';
    }

    public function rules(): array
    {
        return [
            'name' => [
                'required',
                'string',
                'min:2',
                'max:255',
                'unique:service_categories,name',
            ],

            'description' => [
                'nullable',
                'string',
                'max:2000',
            ],

            'image' => [
                'nullable',
                'string',
                'max:255',
            ],

            'display_order' => [
                'nullable',
                'integer',
                'min:0',
            ],
        ];
    }
}